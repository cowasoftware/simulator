/*
 * Copyright 2012-2022
 * All rights reserved.
 */

#ifndef COMMON_CLIENT_HEADER_
#define COMMON_CLIENT_HEADER_
#define ZMQ_MONITOR_ADDR "inproc://monitor"

#include <memory>
#include <string>
#include <thread>
#include <zmq.hpp>

class TcpClient : public std::enable_shared_from_this<TcpClient> {
 public:
  using Ptr = std::shared_ptr<TcpClient>;
  using func_task = std::function<void()>;
  TcpClient(std::string url);
  virtual ~TcpClient();

  void set_req_socket_listener(const func_task& task);
  std::string send(const std::string& data);

 private:
  void connect();
  std::string _url;
  zmq::context_t _ctx;
  zmq::socket_t _socket;
  zmq::socket_t _monitor;
};

class RespInterface : public std::enable_shared_from_this<RespInterface> {
 public:
  typedef enum {
    ERROR_NET_CONNECT = 1,
    ERROR_NET_RECV,
  } Errno;

 public:
  using Ptr = std::shared_ptr<RespInterface>;
  virtual ~RespInterface() = default;
  virtual void onRecv(const std::string&) = 0;
  virtual void onError(Errno err) = 0;
};

class Subscriber : public std::enable_shared_from_this<Subscriber> {
 public:
  using Ptr = std::shared_ptr<Subscriber>;
  static Ptr start(std::string url, RespInterface::Ptr listener);

  Subscriber(std::string url);
  virtual ~Subscriber();
  void run();
  void stop() { _stop = true; }
  void set_listener(RespInterface* callback) { _listener = callback; }

 protected:
  void onRecv(const std::string& data)
  {
    if (_listener) { _listener->onRecv(data); }
  }
  void onError(RespInterface::Errno err)
  {
    if (_listener) _listener->onError(err);
  }

 private:
  void connect();
  bool _stop = false;
  std::string _url;
  zmq::context_t _ctx;
  zmq::socket_t _socket;
  RespInterface* _listener = nullptr;
};

#endif