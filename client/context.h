/*
 * Copyright 2012-2022
 * All rights reserved.
 */

#ifndef CLIENT_CONTEXT_HEADER_
#define CLIENT_CONTEXT_HEADER_

#include <memory>

#include "client/blockingconcurrentqueue.h"
#include "client/client.h"
class Context {
 public:
  using func_task = std::function<void()>;
  static void setIP(std::string& ip) { s_ip_ = std::move(ip); }
  static void setPort(int port) { s_port_ = port; }

  Context();
  virtual ~Context();

  void setRespInterface(RespInterface* resp) { _subscriber->set_listener(resp); }

  std::string send(const std::string& data) { return _client->send(data); }

  void setSocketListener(const func_task& task) { _client->set_req_socket_listener(task); }

 private:
  void clear();
  // input
  Subscriber::Ptr _subscriber;
  // output
  TcpClient::Ptr _client;

  static std::string s_ip_;
  static int s_port_;
};

#endif
