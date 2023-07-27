/*
 * Copyright 2012-2022
 * All rights reserved.
 */

#include "client/logger.h"

#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <mutex>
#include <thread>

#if defined(_WIN32) || defined(_WIN64)
#include <time.h>
static struct tm* localtime_r(const time_t* timep, struct tm* result) {
  localtime_s(result, timep);
  return result;
}
#endif

#ifdef ENABLE_SPD_LOGGER
#include "spdlog/sinks/basic_file_sink.h"
#include "spdlog/sinks/stdout_color_sinks.h"
#include "spdlog/spdlog.h"
#endif

SinkType Logger::s_sinck_type = DEFAULT_SINK;
std::atomic<int> Logger::s_file_level(static_cast<int>(DEFAULT_FILE_LEVEL));
std::atomic<int> Logger::s_console_level(
    static_cast<int>(DEFAULT_CONSOLE_LEVEL));
std::string Logger::s_log_file_name(DEFAULT_LOG_FILE_NAME);
static std::mutex s_global_mutex;
thread_local std::string gl_thread_name = "";

#ifdef ENABLE_SPD_LOGGER
static auto s_console_sink =
    std::make_shared<spdlog::sinks::stdout_color_sink_mt>();
static auto s_file_sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(
    DEFAULT_LOG_FILE_NAME, false);
static spdlog::logger s_spd_logger("multi_sink", s_console_sink);
static spdlog::level::level_enum getLevelMapping(Level level_in) {
  switch (level_in) {
    case TRACE_LEVEL:
      return spdlog::level::trace;
      break;
    case DEBUG_LEVEL:
      return spdlog::level::debug;
      break;
    case INFO_LEVEL:
      return spdlog::level::info;
      break;
    case WARN_LEVEL:
      return spdlog::level::warn;
      break;
    case ERROR_LEVEL:
      return spdlog::level::err;
      break;
    case FATAL_LEVEL:
      return spdlog::level::critical;
      break;
    default:
      std::abort();
      break;
  }
}
#endif

void Logger::setSinkType(SinkType sink) {
  std::lock_guard<std::mutex> lg(s_global_mutex);
  s_sinck_type = sink;

#ifdef ENABLE_SPD_LOGGER
  if (s_sinck_type == SINK_FILE) {
    s_spd_logger = spdlog::logger("multi_sink", s_file_sink);
  } else if (s_sinck_type == SINK_CONSOLE) {
    s_spd_logger = spdlog::logger("multi_sink", s_console_sink);
  } else if (s_sinck_type == SINK_ALL) {
    s_spd_logger = spdlog::logger("multi_sink", {s_console_sink, s_file_sink});
  } else {
    std::abort();
  }
  s_spd_logger.set_level(spdlog::level::trace);
#endif
}

void Logger::setFileInfo(const char* log_file_name, Level level) {
  int level_value = static_cast<int>(level);
  std::unique_lock<std::mutex> lg(s_global_mutex);
  bool unchanged = std::string(log_file_name) == s_log_file_name &&
                           level_value == s_file_level
                       ? true
                       : false;
  bool file_name_changed =
      std::string(log_file_name) != s_log_file_name ? true : false;
  lg.unlock();
  if (unchanged) {
    return;
  }

  s_file_level.store(level_value);
  if (file_name_changed) {
    lg.lock();
    s_log_file_name = std::string(log_file_name);
    lg.unlock();
  }
#ifdef ENABLE_SPD_LOGGER
  lg.lock();
  if (file_name_changed) {
    std::cout << "set new file logger" << std::endl;
    s_file_sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(
        s_log_file_name, false);
    if (s_sinck_type == SINK_FILE) {
      s_spd_logger = spdlog::logger("multi_sink", s_file_sink);
    } else if (s_sinck_type == SINK_CONSOLE) {
      s_spd_logger = spdlog::logger("multi_sink", s_console_sink);
    } else if (s_sinck_type == SINK_ALL) {
      s_spd_logger =
          spdlog::logger("multi_sink", {s_console_sink, s_file_sink});
    } else {
      std::abort();
    }
    s_spd_logger.set_level(spdlog::level::trace);
  }
  s_file_sink->set_level(getLevelMapping(level));
  lg.unlock();
#endif
}

void Logger::setConsoleInfo(Level level) {
  int level_value = static_cast<int>(level);
  std::unique_lock<std::mutex> lg(s_global_mutex);
  bool unchangeed = level_value == s_console_level ? true : false;
  lg.unlock();
  if (unchangeed) {
    return;
  }

  s_console_level.store(level_value);
#ifdef ENABLE_SPD_LOGGER
  lg.lock();
  s_console_sink->set_level(getLevelMapping(level));
  lg.unlock();
#endif
}

void Logger::setThreadName(std::string thread_name) {
  gl_thread_name = thread_name;
}

std::string Logger::getThreadName() {
  if (gl_thread_name == "") {
    auto thread_id = std::this_thread::get_id();
    std::stringstream stream;
    stream << thread_id;
    gl_thread_name = std::string(stream.str());
  }
  return gl_thread_name;
}

Logger::Logger(const char* file_name, int line_num, Level log_level)
    : _file_name(file_name), _line_number(line_num), _log_level(log_level) {
#ifdef ENABLE_SPD_LOGGER
  static std::once_flag of;
  std::call_once(of, [&]() { initSpdlog(); });
#endif
}

Logger::~Logger() {
  this->logToPrint();
  if (_log_level >= FATAL_LEVEL) {
    std::abort();
  }
}

#ifdef ENABLE_SPD_LOGGER
void Logger::initSpdlog() {
  s_console_sink->set_level(getLevelMapping(Level(s_console_level.load())));
  s_console_sink->set_pattern("%C-%m-%d %H:%M:%S:%u [%^%L%$] [%t] [%@] %v");
  s_file_sink->set_level(getLevelMapping(Level(s_file_level.load())));
  s_spd_logger.set_level(spdlog::level::trace);
}

void Logger::spdlogPrint() {
  switch (_log_level) {
    case TRACE_LEVEL:
      s_spd_logger.trace(str());
      break;
    case DEBUG_LEVEL:
      s_spd_logger.debug(str());
      break;
    case INFO_LEVEL:
      s_spd_logger.info(str());
      break;
    case WARN_LEVEL:
      s_spd_logger.warn(str());
      break;
    case ERROR_LEVEL:
      s_spd_logger.error(str());
      break;
    case FATAL_LEVEL:
      s_spd_logger.critical(str());
      break;

    default:
      break;
  }
}
#endif

void Logger::logToPrint() {
  {
    std::lock_guard<std::mutex> lock(s_global_mutex);
    bool need_return = _log_level < s_console_level && _log_level < s_file_level
                           ? true
                           : false;
    if (need_return) {
      return;
    }
  }

#ifdef ENABLE_SPD_LOGGER
  spdlogPrint();
#else
  normalPrint();
#endif
}

bool Logger::checkLevel(Level level) {
  bool enable_print = false;
  if (s_sinck_type == SINK_CONSOLE) {
    enable_print = level >= s_console_level ? true : false;
  } else if (s_sinck_type == SINK_FILE) {
    enable_print = level >= s_file_level ? true : false;
  } else if (s_sinck_type == SINK_ALL) {
    enable_print =
        level >= s_console_level || level >= s_file_level ? true : false;
  }
  return enable_print;
}

void Logger::normalPrint() {
  struct std::tm currTm = {0};
  auto now = std::chrono::system_clock::now();
  std::time_t t_now = std::chrono::system_clock::to_time_t(now);
  auto duration_in_micro =
      std::chrono::duration_cast<std::chrono::microseconds>(
          now.time_since_epoch());
  auto micro_time = duration_in_micro % 1000000;

  const char log_level_names[] = "TDIWEF";
  std::stringstream stream;

  std::unique_lock<std::mutex> lock(s_global_mutex);
  stream << "[" << getThreadName() << "] "
         << std::put_time(localtime_r(&t_now, &currTm), "%Y-%m-%d %H:%M:%S")
         << "." << std::setfill('0') << std::setw(6) << micro_time.count()
         << ": " << log_level_names[static_cast<int>(_log_level)] << " "
         << _file_name << ":" << _line_number << " " << str() << std::endl;

  bool b_log_to_console = s_sinck_type == SINK_ALL ? true : false;
  bool b_log_to_file = s_sinck_type == SINK_ALL ? true : false;
  if ((s_sinck_type == SINK_CONSOLE || b_log_to_console) &&
      _log_level >= s_console_level) {
    std::cout << stream.str();
  }

  if ((s_sinck_type == SINK_FILE || b_log_to_file) &&
      _log_level >= s_file_level) {
    std::fstream of(s_log_file_name, std::ios::app);
    if (!of.is_open()) {
      std::abort();
    }
    of << stream.str();
    of.close();
  }
  lock.unlock();
}