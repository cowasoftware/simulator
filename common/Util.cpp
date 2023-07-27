#include "Util.h"

#include <stdarg.h>
#include <unistd.h>

#include <algorithm>
#include <thread>

uint32_t Util::SystemThreadId() {
#ifdef _WIN32
  return ::GetCurrentThreadId();
  // return ((_Thrd_t*)(char*)&(std::this_thread::get_id()))->_Id;
#elif __unix__
  std::thread::id threadId = std::this_thread::get_id();
  return (uint32_t)(*(__gthread_t*)(char*)(&threadId));
#endif
}

std::string Util::GetName(const std::string& path, int32_t flag) {
  int32_t left = (int32_t)path.find_last_of("/\\");
  std::string name = path.substr(left + 1, path.length() - left - 1);
  int32_t point = (int32_t)name.find_last_of(".");
  switch (flag) {
    case 1: {
      return name;
    }
    case 2: {
      return name.substr(point + 1,
                         point == -1 ? 0 : name.length() - point - 1);
    }
    case 3: {
      return name.substr(0, point == -1 ? name.length() : point);
    }
    case 4: {
      return path.substr(0, left + 1);
    }
    default:
      return "";
  }
}

std::string Util::GetCurrentExePath() {
  char szFilePath[1024] = {};
#ifdef _WIN32
  ::GetModuleFileNameA(NULL, szFilePath, 1024);
#elif __unix__
  if (::readlink("/proc/self/exe", szFilePath, 1024) == -1)
  {
    return "";
  }
#endif
  return Util::GetName(szFilePath, 4);
}

size_t Util::Replace(std::string& str, const std::string& oldstr,
                     const std::string& newstr) {
  size_t count = 0;
  size_t pos = 0;
  while (true) {
    pos = str.find(oldstr, pos);
    if (pos == std::string::npos) {
      break;
    }
    str.replace(pos, oldstr.length(), newstr);
    pos += newstr.length();
    ++count;
  }
  return count;
}

std::string Util::Replace(const char* str, const std::string& oldstr,
                          const std::string& newstr) {
  if (str == nullptr) {
    return std::string();
  }
  std::string result = str;
  Replace(result, oldstr, newstr);
  return result;
}

size_t Util::Replace(std::wstring& str, const std::wstring& oldstr,
                     const std::wstring& newstr) {
  size_t count = 0;
  size_t pos = 0;
  while (true) {
    pos = str.find(oldstr, pos);
    if (pos == std::wstring::npos) {
      break;
    }
    str.replace(pos, oldstr.length(), newstr);
    pos += newstr.length();
    ++count;
  }
  return count;
}

size_t Util::Replace(std::string& str, char ch1, char ch2) {
  size_t count = 0;
  for (size_t pos = 0; pos != str.size(); ++pos) {
    if (str[pos] == ch1) {
      str[pos] = ch2;
      ++count;
    }
  }
  return count;
}

void Util::Format(std::string& str, const char* fmt, ...) {
  va_list args;
  va_start(args, fmt);
#ifdef _WIN32
  int size = _vscprintf(fmt, args);
#elif __unix__
  va_list argcopy;
  va_copy(argcopy, args);
  int size = vsnprintf(nullptr, 0, fmt, argcopy);
#endif
  //?resize分配后string类会自动在最后分配\0，resize(5)则总长6
  str.resize(size);
  if (size != 0) {
#ifdef _WIN32
    //?即便分配了足够内存，长度必须加1，否则会崩溃
    vsprintf_s(&str[0], size + 1, fmt, args);
#elif __unix__
    vsnprintf(&str[0], size + 1, fmt, args);
#endif
  }
  va_end(args);
}

std::string Util::Format(const char* fmt, ...) {
  std::string result;
  va_list args;
  va_start(args, fmt);
#ifdef _WIN32
  int size = _vscprintf(fmt, args);
#elif __unix__
  va_list argcopy;
  va_copy(argcopy, args);
  int size = vsnprintf(nullptr, 0, fmt, argcopy);
#endif
  //?resize分配后string类会自动在最后分配\0，resize(5)则总长6
  result.resize(size);
  if (size != 0) {
#ifdef _WIN32
    //?即便分配了足够内存，长度必须加1，否则会崩溃
    vsprintf_s(&result[0], size + 1, fmt, args);
#elif __unix__
    vsnprintf(&result[0], size + 1, fmt, args);
#endif
  }
  va_end(args);
  return result;
}

std::string Util::MakeUpper(const std::string& src) {
  std::string dst;
#if defined _MSC_VER && (_MSC_VER < 1800)
  return dst;
#endif
  //如果dst是有值的话则第三个参数传dst.begin()，从头开始覆盖
  std::transform(src.begin(), src.end(), std::back_inserter(dst), ::toupper);
  return dst;
}

std::string Util::MakeLower(const std::string& src) {
  std::string dst;
#if defined _MSC_VER && (_MSC_VER < 1800)
  return dst;
#endif
  std::transform(src.begin(), src.end(), std::back_inserter(dst), ::tolower);
  return dst;
}

std::wstring Util::MakeUpper(const std::wstring& src) {
  std::wstring dst;
#if defined _MSC_VER && (_MSC_VER < 1800)
  return dst;
#endif
  std::transform(src.begin(), src.end(), std::back_inserter(dst), ::toupper);
  return dst;
}

std::wstring Util::MakeLower(const std::wstring& src) {
  std::wstring dst;
#if defined _MSC_VER && (_MSC_VER < 1800)
  return dst;
#endif
  std::transform(src.begin(), src.end(), std::back_inserter(dst), ::tolower);
  return dst;
}

std::chrono::high_resolution_clock::time_point Util::GetHighTickCount()
{
	return std::chrono::high_resolution_clock::now();
}

int32_t Util::GetHighTickCountMicroRunTime(const std::chrono::high_resolution_clock::time_point& beginTime)
{
	return (int32_t)std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - beginTime).count();
}

std::string Util::ReadFile(const std::string& path)
{
	FILE* file = fopen(path.c_str(), "rb");
	if (file == nullptr)
	{
		return "";
	}
	fseek(file, 0, SEEK_END);
	long length = ftell(file);
	fseek(file, 0, SEEK_SET);
	std::string result;
	result.resize(length);
	fread(&result[0], 1, length, file);
	fclose(file);
	return result;
}

bool Util::DirOrFileExist(const std::string& path)
{
#ifdef _MSC_VER
	return _access(path.c_str(), 0) == 0;
#elif __unix__
	return access(path.c_str(), 0) == 0;
#endif
}

std::vector<std::string> Util::Split(const std::string& splitString, const std::string& separate_character)
{
	std::vector<std::string> strs;
	//?分割字符串的长度,这样就可以支持如“,,”多字符串的分隔符
	size_t separate_characterLen = separate_character.length();
	size_t lastPosition = 0;
	int32_t index = -1;
	while (-1 != (index = (int32_t)splitString.find(separate_character, lastPosition)))
	{
		strs.push_back(splitString.substr(lastPosition, index - lastPosition));
		lastPosition = index + separate_characterLen;   
	}
	//?截取最后一个分隔符后的内容
	//?if (!lastString.empty()) //如果最后一个分隔符后还有内容就入队
	strs.push_back(splitString.substr(lastPosition));
	return strs;
}

std::string Util::GetBuildVersion() {
  std::string buildVersion = std::string(SIM_CLIENT_BUILD_VERSION);
  return buildVersion;
}

std::string Util::GetBuildTime() {
  std::string buildTime = std::string(SIM_CLIENT_BUILD_TIME);
  return buildTime;
}