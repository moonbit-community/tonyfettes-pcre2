///|
test "captures" {
  let code = @pcre2.compile("(?<hello>hello)")
  let subject = "a hello, 你好  world! hello"
  let views = []
  let matches = code.matches(subject)
  while matches.next() is Some(matched) {
    for _, capture in matched.named_groups() {
      views.push(capture.to_string())
    }
  }
  @json.inspect(views, content=["hello", "hello"])
}

///|
test "named_groups" {
  let code = @pcre2.compile("(?<num>\\d+)")
  let matches = code.matches("number: 42")
  let match_result = matches.next().unwrap()
  @json.inspect(match_result["num"], content="42")
}

///|
test "split" {
  let code = @pcre2.compile(
    "'s|'t|'re|'ve|'m|'ll|'d| ?\\p{L}+| ?\\p{N}+| ?[^\\s\\p{L}\\p{N}]+|\\s+(?!\\S)|\\s+",
  )
  let subject = "He's a good person"
  let splits = []
  let matches = code.matches(subject)
  while matches.next() is Some(match_) {
    for _, capture in match_.groups() {
      splits.push(capture.to_string())
    }
  }
  @json.inspect(splits, content=["He", "'s", " a", " good", " person"])
}

///|
test "cl100k_base" {
  let code = @pcre2.compile(
    "'(?i:[sdmt]|ll|ve|re)|[^\\r\\n\\p{L}\\p{N}]?+\\p{L}++|\\p{N}{1,3}+| ?[^\\s\\p{L}\\p{N}]++[\\r\\n]*+|\\s++$|\\s*[\\r\\n]|\\s+(?!\\S)|\\s",
  )
  let subject = "你好，世界🌍"
  let splits = []
  let matches = code.matches(subject)
  while matches.next() is Some(matched) {
    splits.push(matched[0])
  }
  @json.inspect(splits, content=["你好", "，世界", "🌍"])
}

///|
test "cl100k_base/view" {
  let code = @pcre2.compile(
    "'(?i:[sdmt]|ll|ve|re)|[^\\r\\n\\p{L}\\p{N}]?+\\p{L}++|\\p{N}{1,3}+| ?[^\\s\\p{L}\\p{N}]++[\\r\\n]*+|\\s++$|\\s*[\\r\\n]|\\s+(?!\\S)|\\s",
  )
  let subject = "abcdefg你好，世界🌍"
  let subject = subject[7:]
  @json.inspect(subject, content="你好，世界🌍")
  let splits = []
  let matches = code.matches(subject)
  while matches.next() is Some(matched) {
    splits.push(matched[0])
  }
  @json.inspect(splits, content=["你好", "，世界", "🌍"])
}

///|
test "substitution" {
  let code = @pcre2.compile("\\b(\\w+)\\b")
  let subject = "Hello world!"
  let matches = code.matches(subject)
  let results = []
  while matches.next() is Some(matched) {
    results.push(matched[0].to_string())
  }
  @json.inspect(results, content=["Hello", "world"])
  @json.inspect(
    code.substitute(subject, "<$1>", global=true),
    content="<Hello> <world>!",
  )
}

///|
test "substitution/view" {
  let code = @pcre2.compile("\\b(\\w+)\\b")
  let subject = "Hello world!"
  let subject = subject[6:11]
  @json.inspect(subject, content="world")
  let matches = code.matches(subject)
  let results = []
  while matches.next() is Some(matched) {
    results.push(matched[0].to_string())
  }
  @json.inspect(results, content=["world"])
  let replacement = "<<$1>>"
  let replacement = replacement[1:5]
  @json.inspect(replacement, content="<$1>")
  @json.inspect(
    code.substitute(subject, replacement, global=true),
    content="<world>",
  )
}

///|
test "jit_compile" {
  let code = @pcre2.compile("(?<hello>hello)")
  code.jit_compile(complete=true)
  let subject = "a hello, 你好  world! hello"
  let views = []
  let matches = code.matches(subject)
  while matches.next() is Some(matched) {
    for _, capture in matched.named_groups() {
      views.push(capture.to_string())
    }
  }
  @json.inspect(views, content=["hello", "hello"])
}

///|
test "cl100k_base/jit_compile" (b : @bench.T) {
  let code = @pcre2.compile(
    "'(?i:[sdmt]|ll|ve|re)|[^\\r\\n\\p{L}\\p{N}]?+\\p{L}++|\\p{N}{1,3}+| ?[^\\s\\p{L}\\p{N}]++[\\r\\n]*+|\\s++$|\\s*[\\r\\n]|\\s+(?!\\S)|\\s",
  )
  let subject =
    #|A typhoon is a tropical cyclone that develops between 180° and 100°E in the East hemisphere and which produces sustained hurricane-force winds of at least 119 km/h (74 mph).[1] This region is referred to as the Northwestern Pacific Basin,[2] accounting for almost one third of the world's tropical cyclones. For organizational purposes, the northern Pacific Ocean is divided into three regions: the eastern (North America to 140°W), central (140°W to 180°), and western (180° to 100°E). The Regional Specialized Meteorological Center (RSMC) for tropical cyclone forecasts is in Japan, with other tropical cyclone warning centres for the northwest Pacific in Hawaii (the Joint Typhoon Warning Center), the Philippines, and Hong Kong. Although the RSMC names each system, the main name list itself is coordinated among 18 countries that have territories threatened by typhoons each year.[3]
    #|
    #|Within most of the northwestern Pacific, there are no official typhoon seasons as tropical cyclones form throughout the year. Like any tropical cyclone, there are several main requirements for typhoon formation and development. It must be in sufficiently warm sea surface temperatures, atmospheric instability, high humidity in the lower-to-middle levels of the troposphere, have enough Coriolis effect to develop a low pressure centre, a pre-existing low level focus or disturbance, and a low vertical wind shear. Although the majority of storms form between June and November, a few storms may occur between December and May (although tropical cyclone formation is very rare during that time). On average, the northwestern Pacific features the most numerous and intense tropical cyclones globally. Like other basins, they are steered by the subtropical ridge towards the west or northwest, with some systems recurving near and east of Japan. The Philippines receive the brunt of the landfalls, with China and Japan being less often impacted. However, some of the deadliest typhoons in history have struck China. Southern China has the longest record of typhoon impacts for the region, with a thousand-year sample via documents within their archives. Taiwan has received the wettest known typhoon on record for the northwest Pacific tropical cyclone basins. However, Vietnam recognises its typhoon season as lasting from the beginning of June through to the end of November, with an average of four to six typhoons hitting the country annually.[4][5]
    #|
    #|According to the statistics of the Joint Typhoon Warning Center, from 1950 to 2022, the Northwest Pacific generated an average of 26.5 named tropical cyclones each year, of which an average of 16.6 reached typhoon standard or above as defined by the Joint Typhoon Warning Center.[6]"
  b.bench(name="baseline", () => try {
    let matches = code.matches(subject)
    while matches.next() is Some(_) {
      // do nothing
    }
  } catch {
    _ => ()
  })
  code.jit_compile()
  b.bench(name="jit", () => try {
    let matches = code.matches(subject)
    while matches.next() is Some(_) {
      // do nothing
    }
  } catch {
    _ => ()
  })
}
