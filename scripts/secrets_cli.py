#!/usr/bin/env python3
"""命令行工具：封装 sops 与 age 的常用操作。"""

from __future__ import annotations

import argparse
import os
import pathlib
import stat
import subprocess
import sys
import tempfile
from typing import Iterable, List


def _expand(path: str) -> pathlib.Path:
    return pathlib.Path(os.path.expanduser(path)).resolve()


def _default_key_path() -> str:
    return os.path.expanduser(os.environ.get("SOPS_AGE_KEY_FILE", "~/.config/sops/age/keys.txt"))


def _ensure_key_in_env(env: dict) -> dict:
    if "SOPS_AGE_KEY_FILE" not in env or not env["SOPS_AGE_KEY_FILE"]:
        env["SOPS_AGE_KEY_FILE"] = _default_key_path()
    return env


def _run_sops(
    args: List[str], *, stdout=None, env: dict | None = None, capture_output: bool = False
) -> subprocess.CompletedProcess[str]:
    base_env = os.environ.copy()
    if env is not None:
        base_env.update(env)
    runtime_env = _ensure_key_in_env(base_env)
    run_kwargs: dict = {"check": True, "env": runtime_env, "text": True}
    if stdout is not None:
        run_kwargs["stdout"] = stdout
    elif capture_output:
        run_kwargs["stdout"] = subprocess.PIPE
        run_kwargs["stderr"] = subprocess.PIPE
    return subprocess.run(args, **run_kwargs)


def _age_key(args: argparse.Namespace) -> None:
    path = _expand(args.key_path)
    path.parent.mkdir(parents=True, exist_ok=True)

    if path.exists():
        print(f"Age 私钥已存在: {path}")
        return

    result = subprocess.run(["age-keygen"], check=True, capture_output=True, text=True)
    path.write_text(result.stdout)
    path.chmod(stat.S_IRUSR | stat.S_IWUSR)
    print(f"已生成 Age 私钥: {path}")


def _encrypt(args: argparse.Namespace) -> None:
    recipients: List[str] = [r for r in args.recipients if r]
    if not recipients:
        print("必须通过 --recipients 指定至少一个 Age 公钥", file=sys.stderr)
        raise SystemExit(2)

    source = _expand(args.source)
    target = _expand(args.target)

    if not source.exists():
        print(f"未找到待加密文件: {source}", file=sys.stderr)
        raise SystemExit(1)

    target.parent.mkdir(parents=True, exist_ok=True)

    cmd: List[str] = [
        "sops",
        "--encrypt",
        "--input-type",
        "yaml",
        "--output-type",
        args.output_type,
    ]
    for recipient in recipients:
        cmd += ["--age", recipient]
    cmd.append(str(source))

    with target.open("w", encoding="utf-8") as fh:
        _run_sops(cmd, stdout=fh)
    print(f"已写入密文: {target}")


def _decrypt(args: argparse.Namespace) -> None:
    target = _expand(args.target)
    cmd = [
        "sops",
        "--decrypt",
        "--input-type",
        "yaml",
        "--output-type",
        args.output_type,
        str(target),
    ]
    _run_sops(cmd)


def _edit(args: argparse.Namespace) -> None:
    target = _expand(args.target)
    recipients: List[str] = [r for r in args.recipients if r]

    if (not target.exists() or target.stat().st_size == 0) and not recipients:
        print("首次创建密文时请通过 --recipients 提供 Age 公钥", file=sys.stderr)
        raise SystemExit(2)

    cmd: List[str] = ["sops"]
    for recipient in recipients:
        cmd += ["--age", recipient]
    cmd.append(str(target))
    _run_sops(cmd)


def _smoke(args: argparse.Namespace) -> None:
    source = _expand(args.source)
    if not source.exists():
        print(f"未找到示例文件: {source}", file=sys.stderr)
        raise SystemExit(1)

    previous_key = os.environ.get("SOPS_AGE_KEY_FILE")

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = pathlib.Path(tmpdir)
        key_path = tmp_path / "age.key"
        encrypted_path = tmp_path / "cfg.secrets.yaml"

        try:
            os.environ["SOPS_AGE_KEY_FILE"] = str(key_path)
            _age_key(argparse.Namespace(key_path=str(key_path)))
            public_key = ""
            for line in key_path.read_text().splitlines():
                if line.startswith("# public key:"):
                    public_key = line.split()[-1]
                    break

            if not public_key:
                print("未能从 Age 私钥解析公钥", file=sys.stderr)
                raise SystemExit(1)

            _encrypt(
                argparse.Namespace(
                    recipients=[public_key],
                    source=str(source),
                    target=str(encrypted_path),
                )
            )

            decrypt_cmd = [
                "sops",
                "--decrypt",
                "--input-type",
                "yaml",
                "--output-type",
                "yaml",
                str(encrypted_path),
            ]
            env = {"SOPS_AGE_KEY_FILE": str(key_path)}
            result = _run_sops(decrypt_cmd, env=env, capture_output=True)

            if not result.stdout.strip():
                print("解密结果为空", file=sys.stderr)
                raise SystemExit(1)

            print("SOPS/Age 烟雾测试通过，成功加密并解密示例配置。")
        finally:
            if previous_key is None:
                os.environ.pop("SOPS_AGE_KEY_FILE", None)
            else:
                os.environ["SOPS_AGE_KEY_FILE"] = previous_key


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="shinx 仓库密钥操作工具")
    sub = parser.add_subparsers(dest="command", required=True)

    age_key = sub.add_parser("age-key", help="生成或复用 Age 私钥")
    age_key.add_argument("--key-path", default="~/.config/sops/age/keys.txt", help="Age 私钥存储路径")
    age_key.set_defaults(func=_age_key)

    encrypt = sub.add_parser("encrypt", help="加密 cfg.secrets.yaml")
    encrypt.add_argument("--recipients", nargs="+", help="Age 公钥列表 (可指定多个)")
    encrypt.add_argument("--source", default="secrets/cfg.secrets.yaml.example", help="明文 YAML 路径")
    encrypt.add_argument("--target", default="secrets/cfg.secrets.yaml", help="输出密文路径")
    encrypt.add_argument(
        "--output-type",
        choices=["yaml", "json"],
        default="yaml",
        help="密文存储格式",
    )
    encrypt.set_defaults(func=_encrypt)

    decrypt = sub.add_parser("decrypt", help="解密并输出 cfg.secrets.yaml")
    decrypt.add_argument("--target", default="secrets/cfg.secrets.yaml", help="密文路径")
    decrypt.add_argument(
        "--output-type",
        choices=["yaml", "json"],
        default="yaml",
        help="解密输出格式",
    )
    decrypt.set_defaults(func=_decrypt)

    edit = sub.add_parser("edit", help="使用 sops 直接编辑密文")
    edit.add_argument("--target", default="secrets/cfg.secrets.yaml", help="密文路径")
    edit.add_argument("--recipients", nargs="*", default=[], help="首次创建时附加的 Age 公钥")
    edit.set_defaults(func=_edit)

    smoke = sub.add_parser("smoke", help="在临时目录生成密钥并完成加解密验证")
    smoke.add_argument(
        "--source",
        default="secrets/cfg.secrets.yaml.example",
        help="用于烟雾测试的示例 YAML",
    )
    smoke.set_defaults(func=_smoke)

    return parser


def main(argv: Iterable[str] | None = None) -> None:
    parser = _parser()
    args = parser.parse_args(argv)
    args.func(args)


if __name__ == "__main__":
    main()
