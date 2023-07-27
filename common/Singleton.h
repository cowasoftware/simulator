#ifndef _SINGLETON_H__
#define _SINGLETON_H__

#include <mutex>

//单例模板类
template <class T>
class Singleton {
 public:
  static T* getInstance() {
    //判断是否第一次调用
    if (m_pInstance == nullptr) {
      m_garbo.init();
      m_locker.lock();
      if (m_pInstance == nullptr) {
        m_pInstance = new T();
      }
      m_locker.unlock();
    }
    return m_pInstance;
  }

 protected:
  //使继承者无法public构造函数和析构函数
  Singleton() {}
  ~Singleton() {}

 private:
  //禁止拷贝构造和赋值运算符. The only way is getInstance()
  Singleton(const Singleton& src) = delete;
  Singleton& operator=(const Singleton& src) = delete;

  //它的唯一工作就是在析构函数中析构Singleton的实例，所以private
  class Garbo {
   public:
    ~Garbo() {
      if (Singleton::m_pInstance != nullptr) {
        delete Singleton::m_pInstance;
        Singleton::m_pInstance = nullptr;
      }
    }

    void init() {}
  };

 private:
  static std::mutex m_locker;
  static T* m_pInstance;
  static Garbo m_garbo;
};

template <typename T>
std::mutex Singleton<T>::m_locker;

//必须初始化这个静态成员，初始化的过程中会分配内存，否则无法访问
template <class T>
T* Singleton<T>::m_pInstance = nullptr;

template <class T>
typename Singleton<T>::Garbo Singleton<T>::m_garbo;

#endif  // _SINGLETON_H__