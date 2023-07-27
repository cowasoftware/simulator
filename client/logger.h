/*
 * Copyright 2012-2022
 * All rights reserved.
 */

#ifndef LOGGER_INTERNAL_HEADER_
#define LOGGER_INTERNAL_HEADER_
#include <atomic>
#include <sstream>
#include <string>

typedef enum {
  NONE_LEVEL = -1,
  TRACE_LEVEL,
  DEBUG_LEVEL,
  INFO_LEVEL,
  WARN_LEVEL,
  ERROR_LEVEL,
  FATAL_LEVEL,
  MAX_LEVEL,
} Level;

#define DEFAULT_CONSOLE_LEVEL DEBUG_LEVEL
#define DEFAULT_FILE_LEVEL INFO_LEVEL

typedef enum {
  SINK_CONSOLE = 0,
  SINK_FILE = 1,
  SINK_ALL = 2,
  SINK_MAX,
} SinkType;

#define DEFAULT_SINK SINK_CONSOLE
#define DEFAULT_LOG_FILE_NAME "log_file.log"

class Logger : public std::basic_ostringstream<char> {
 public:
  Logger(const char* file_name, int line_num, Level log_level);
  virtual ~Logger();
  virtual void logToPrint();

  static void setSinkType(SinkType sink);
  static void setFileInfo(const char* log_file_name, Level level = INFO_LEVEL);
  static void setConsoleInfo(Level level = DEBUG_LEVEL);
  static void setThreadName(std::string thread_name);
  static bool checkLevel(Level level);

 private:
  static SinkType s_sinck_type;
  static std::atomic<int> s_file_level;
  static std::atomic<int> s_console_level;
  static std::string s_log_file_name;
  static std::string getThreadName();

  std::string _file_name;
  int _line_number;
  Level _log_level;

 private:
  void normalPrint();
#ifdef ENABLE_SPD_LOGGER
  void spdlogPrint();
  static void initSpdlog();
#endif
};

class NoneType {
 public:
  template <typename T>
  void operator&(T&& t) const {}
};

#define LEVEL_IS_ON(level) Logger::checkLevel(level)
#define LOG_STREAM_CONTENT(level) \
  !LEVEL_IS_ON(level) ? (void)0   \
                      : NoneType() & Logger(__FILE__, __LINE__, (level))

#define LOG_CONTENT(level, ...) \
  !LEVEL_IS_ON(level)           \
      ? (void)0                 \
      : NoneType() & Logger(__FILE__, __LINE__, (level)) << __VA_ARGS__

#define CTRACE(...) LOG_CONTENT(TRACE_LEVEL, __VA_ARGS__)
#define CDBG(...) LOG_CONTENT(DEBUG_LEVEL, __VA_ARGS__)
#define CINFO(...) LOG_CONTENT(INFO_LEVEL, __VA_ARGS__)
#define CWARN(...) LOG_CONTENT(WARN_LEVEL, __VA_ARGS__)
#define CERROR(...) LOG_CONTENT(ERROR_LEVEL, __VA_ARGS__)
#define CFATAL(...) LOG_CONTENT(FATAL_LEVEL, __VA_ARGS__)

#define STRACE LOG_STREAM_CONTENT(TRACE_LEVEL)
#define SDBG LOG_STREAM_CONTENT(DEBUG_LEVEL)
#define SINFO LOG_STREAM_CONTENT(INFO_LEVEL)
#define SWARN LOG_STREAM_CONTENT(WARN_LEVEL)
#define SERROR LOG_STREAM_CONTENT(ERROR_LEVEL)
#define SFATAL LOG_STREAM_CONTENT(FATAL_LEVEL)

#ifdef ENABLE_FORMAT_LOGGER_FEATHRE
#include "fmt/core.h"
template <typename FormatString, typename... Args>
void printVars(Level level, const char* file, signed int line,
               const FormatString& fmt, Args&&... args) {
  Logger(file, line, level) << fmt::format(fmt, std::forward<Args>(args)...);
}

#define LOG_CONTENT_BY_FORMAT(level, ...) \
  !LEVEL_IS_ON(level) ? (void)0           \
                      : printVars(level, __FILE__, __LINE__, __VA_ARGS__)

#define FTRACE(...) LOG_CONTENT_BY_FORMAT(TRACE_LEVEL, __VA_ARGS__)
#define FDBG(...) LOG_CONTENT_BY_FORMAT(DEBUG_LEVEL, __VA_ARGS__)
#define FINFO(...) LOG_CONTENT_BY_FORMAT(INFO_LEVEL, __VA_ARGS__)
#define FWARN(...) LOG_CONTENT_BY_FORMAT(WARN_LEVEL, __VA_ARGS__)
#define FERROR(...) LOG_CONTENT_BY_FORMAT(ERROR_LEVEL, __VA_ARGS__)
#define FFATAL(...) LOG_CONTENT_BY_FORMAT(FATAL_LEVEL, __VA_ARGS__)

#endif
#endif