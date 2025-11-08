#include <stdint.h>
#include <time.h>
#define PCRE2_CODE_UNIT_WIDTH 16
#include "pcre2.h"
#include <moonbit.h>

#define static_assert_type_equal(type, expected)                               \
  _Static_assert(                                                              \
    _Generic((type)0, expected: 1, default: 0), #type " is not " #expected     \
  )

typedef struct moonbit_pcre2_code_16 {
  pcre2_code_16 *code;
} moonbit_pcre2_code_16;

static inline void
moonbit_pcre2_code_16_finalize(void *object) {
  moonbit_pcre2_code_16 *code = (moonbit_pcre2_code_16 *)object;
  if (code) {
    if (code->code) {
      pcre2_code_free_16(code->code);
    }
  }
}

int32_t
moonbit_pcre2_get_error_message_16(
  int32_t error_code,
  moonbit_string_t buffer,
  PCRE2_SIZE buffer_length
) {
  int32_t written =
    pcre2_get_error_message_16(error_code, buffer, buffer_length);
  moonbit_decref(buffer);
  return written;
}

moonbit_pcre2_code_16 *
moonbit_pcre2_compile_16(
  moonbit_string_t pattern,
  PCRE2_SIZE length,
  uint32_t options,
  int32_t *error_code,
  PCRE2_SIZE *error_offset,
  pcre2_compile_context_16 *context
) {
  pcre2_code_16 *code = pcre2_compile_16(
    pattern, length, options, error_code, error_offset, context
  );
  moonbit_decref(pattern);
  moonbit_decref(error_code);
  moonbit_decref(error_offset);
  moonbit_pcre2_code_16 *moonbit_code =
    (moonbit_pcre2_code_16 *)moonbit_make_external_object(
      moonbit_pcre2_code_16_finalize, sizeof(pcre2_code_16 *)
    );
  moonbit_code->code = code;
  return moonbit_code;
}

typedef struct moonbit_pcre2_match_data_16 {
  pcre2_match_data_16 *match_data;
} moonbit_pcre2_match_data_16;

static inline void
moonbit_pcre2_match_data_16_finalize(void *object) {
  moonbit_pcre2_match_data_16 *match_data =
    (moonbit_pcre2_match_data_16 *)object;
  if (match_data) {
    if (match_data->match_data) {
      pcre2_match_data_free_16(match_data->match_data);
    }
  }
}

moonbit_pcre2_match_data_16 *
moonbit_pcre2_match_data_create_from_pattern_16(
  moonbit_pcre2_code_16 *code,
  pcre2_general_context_16 *context
) {
  pcre2_match_data_16 *match_data =
    pcre2_match_data_create_from_pattern_16(code->code, context);
  moonbit_decref(code);
  moonbit_pcre2_match_data_16 *moonbit_match_data =
    (moonbit_pcre2_match_data_16 *)moonbit_make_external_object(
      moonbit_pcre2_match_data_16_finalize, sizeof(pcre2_match_data_16 *)
    );
  moonbit_match_data->match_data = match_data;
  return moonbit_match_data;
}

PCRE2_SIZE *
moonbit_pcre2_get_ovector_pointer_16(moonbit_pcre2_match_data_16 *match_data) {
  PCRE2_SIZE *ovector = pcre2_get_ovector_pointer_16(match_data->match_data);
  moonbit_decref(match_data);
  return ovector;
}

PCRE2_SIZE
moonbit_pcre2_get_startchar_16(moonbit_pcre2_match_data_16 *match_data) {
  PCRE2_SIZE startchar = pcre2_get_startchar_16(match_data->match_data);
  moonbit_decref(match_data);
  return startchar;
}

int32_t
moonbit_pcre2_match_16(
  moonbit_pcre2_code_16 *code,
  moonbit_string_t subject,
  PCRE2_SIZE length,
  PCRE2_SIZE start_offset,
  uint32_t options,
  moonbit_pcre2_match_data_16 *match_data,
  pcre2_match_context_16 *match_context
) {
  int32_t captures = pcre2_match_16(
    code->code, subject, length, start_offset, options, match_data->match_data,
    match_context
  );
  moonbit_decref(code);
  moonbit_decref(subject);
  moonbit_decref(match_data);
  return captures;
}

int32_t
moonbit_pcre2_pattern_info_16_uint32(
  moonbit_pcre2_code_16 *code,
  uint32_t what,
  uint32_t *where
) {
  int32_t result = pcre2_pattern_info_16(code->code, what, where);
  moonbit_decref(code);
  moonbit_decref(where);
  return result;
}

int32_t
moonbit_pcre2_pattern_info_16_uint16_pointer(
  moonbit_pcre2_code_16 *code,
  uint32_t what,
  uint16_t **where
) {
  int32_t result = pcre2_pattern_info_16(code->code, what, where);
  moonbit_decref(code);
  moonbit_decref(where);
  return result;
}

int32_t
moonbit_pcre2_substitute_16(
  moonbit_pcre2_code_16 *code,
  moonbit_string_t subject,
  uint64_t subject_offset,
  uint64_t subject_length,
  uint64_t start_offset,
  uint32_t options,
  moonbit_pcre2_match_data_16 *match_data,
  pcre2_match_context_16 *match_context,
  moonbit_string_t replacement,
  uint64_t replacement_offset,
  uint64_t replacement_length,
  moonbit_string_t output_buffer,
  uint64_t *output_length
) {
  size_t pcre2_output_length = *output_length;
  int32_t result = pcre2_substitute_16(
    code->code, (subject + subject_offset), subject_length, start_offset,
    options, match_data->match_data, match_context,
    (replacement + replacement_offset), replacement_length, output_buffer,
    &pcre2_output_length
  );
  *output_length = pcre2_output_length;
  moonbit_decref(code);
  moonbit_decref(subject);
  moonbit_decref(match_data);
  moonbit_decref(replacement);
  moonbit_decref(output_buffer);
  moonbit_decref(output_length);
  return result;
}

int32_t
moonbit_pcre2_config_16_int(uint32_t what, int32_t *where) {
  return pcre2_config_16(what, where);
}

int32_t
moonbit_pcre2_jit_compile_16(moonbit_pcre2_code_16 *code, uint32_t options) {
  int32_t result = pcre2_jit_compile_16(code->code, options);
  moonbit_decref(code);
  return result;
}
