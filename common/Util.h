#pragma once
#include <stdint.h>
#include <chrono>
#include <string>
#include <vector>

class Util
{
 public:
  static uint32_t SystemThreadId();
  static std::string GetName(const std::string& path, int32_t flag);
  static std::string GetCurrentExePath();
  static size_t Replace(std::string& str, const std::string& oldstr,
                        const std::string& newstr);
  static std::string Replace(const char* str, const std::string& oldstr,
                             const std::string& newstr);
  static size_t Replace(std::wstring& str, const std::wstring& oldstr,
                        const std::wstring& newstr);
  static size_t Replace(std::string& str, char ch1, char ch2);
  static std::string MakeUpper(const std::string& src);
  static std::string MakeLower(const std::string& src);
  static std::wstring MakeUpper(const std::wstring& src);
  static std::wstring MakeLower(const std::wstring& src);
  static void Format(std::string& str, const char* fmt, ...);
  static std::string Format(const char* fmt, ...);
  static void Format(std::wstring& str, const wchar_t* fmt, ...);
  static std::wstring Format(const wchar_t* fmt, ...);
  static std::chrono::high_resolution_clock::time_point GetHighTickCount();
	static int32_t GetHighTickCountMicroRunTime(const std::chrono::high_resolution_clock::time_point& beginTime);
  static std::string ReadFile(const std::string& path);
  static bool DirOrFileExist(const std::string& path);
  static std::vector<std::string> Split(const std::string& splitString, const std::string& separate_character);
  static bool endsWith(const std::string& s, const std::string& sub){
      return s.rfind(sub)==(s.length()-sub.length())?true:false;
  }
  static std::string GetBuildVersion();
  static std::string GetBuildTime();
};