import shutil
from pathlib import Path
import json
from typing import Literal

headers = ["pcre2_internal.h"]

sources = [
    "pcre2_auto_possess.c",
    "pcre2_chkdint.c",
    "pcre2_compile.c",
    "pcre2_compile_cgroup.c",
    "pcre2_compile_class.c",
    "pcre2_config.c",
    "pcre2_context.c",
    "pcre2_convert.c",
    "pcre2_dfa_match.c",
    "pcre2_error.c",
    "pcre2_extuni.c",
    "pcre2_find_bracket.c",
    "pcre2_jit_compile.c",
    "pcre2_maketables.c",
    "pcre2_match.c",
    "pcre2_match_data.c",
    "pcre2_newline.c",
    "pcre2_ord2utf.c",
    "pcre2_pattern_info.c",
    "pcre2_script_run.c",
    "pcre2_serialize.c",
    "pcre2_string_utils.c",
    "pcre2_study.c",
    "pcre2_substitute.c",
    "pcre2_substring.c",
    "pcre2_tables.c",
    "pcre2_ucd.c",
    "pcre2_valid_utf.c",
    "pcre2_xclass.c",
]


def prepend_macros(file: Path, macros: list[tuple[str, str]]):
    content = file.read_text()
    for macro in macros:
        content = f"#define {macro[0]} {macro[1]}\n" + content
    file.write_text(content)


CodeUnitWidth = Literal[8, 16, 32]


def prepare(source: Path, target: Path, code_unit_width: CodeUnitWidth):
    if not target.exists():
        target.mkdir(parents=True)
    ignored: list[str] = []
    config_h_content = (source / "config.h.generic").read_text()
    config_h_content += f"""
#define HAVE_MEMMOVE 1
#define HAVE_STRERROR 1
#define SUPPORT_PCRE2_{code_unit_width} 1
#define SUPPORT_UNICODE 1
#define SUPPORT_JIT 1
"""
    (target / "config.h").write_text(config_h_content)
    ignored.append("config.h")
    shutil.copy(source / "pcre2.h.generic", target / "pcre2.h")
    ignored.append("pcre2.h")

    macros = [
        ("HAVE_CONFIG_H", "1"),
        ("PCRE2_CODE_UNIT_WIDTH", str(code_unit_width)),
    ]
    shutil.copy(source / "pcre2_chartables.c.dist", target / "pcre2_chartables.c")
    prepend_macros(target / "pcre2_chartables.c", macros)
    ignored.append("pcre2_chartables.c")
    for h in source.glob("*.h"):
        t = target / (h.relative_to(source))
        print(f"COPY {h} -> {t}")
        shutil.copy(h, t)
        ignored.append(h.relative_to(source).as_posix())

    for s in sources:
        t = target / s
        print(f"COPY {s} -> {t}")
        shutil.copy(source / s, t)
        prepend_macros(t, macros)
        ignored.append(s)
    if (target / "moon.pkg.json").exists():
        moon_pkg_json = json.loads((target / "moon.pkg.json").read_text())
    else:
        moon_pkg_json = {}
    moon_pkg_json["native-stub"] = ["pcre2.c", "pcre2_chartables.c"] + sources
    (target / "moon.pkg.json").write_text(json.dumps(moon_pkg_json, indent=2))

    ignored.sort()
    Path(target / ".gitignore").write_text("\n".join(ignored) + "\n")


def main():
    prepare(Path("src/pcre2/src"), Path("src"), code_unit_width=16)
    if Path("deps").exists():
        shutil.rmtree(Path("deps"))
    # JIT support
    shutil.copytree(Path("src/pcre2/deps"), Path("deps"))


if __name__ == "__main__":
    main()
