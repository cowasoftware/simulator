/*
 * Copyright 2012-2022
 * All rights reserved.
 */

#include "client/client.h"
#include "client/logger.h"
#include <iostream>

TcpClient::TcpClient(std::string url) : _url(url), _ctx(1)
{
  std::thread t([this]() { this->connect(); });
  t.join();
  // this->connect();
}

TcpClient::~TcpClient()
{
  _socket.close();
  _ctx.close();
  _monitor.close();
}

void TcpClient::connect()
{
  _socket = zmq::socket_t(_ctx, ZMQ_REQ);
  int tcp_keep_alive = 1;
  _socket.setsockopt(ZMQ_TCP_KEEPALIVE, &tcp_keep_alive, sizeof(tcp_keep_alive));
  int tcp_keep_idle = 60;
  _socket.setsockopt(ZMQ_TCP_KEEPALIVE_IDLE, &tcp_keep_idle, sizeof(tcp_keep_idle));
  _socket.connect(_url);
  if (_socket.handle() == nullptr) { SFATAL << "connect server with error" << _url; }
  SDBG << "connect success: " << _url;
}

void TcpClient::set_req_socket_listener(const func_task& task)
{
  std::thread monitor_thread([this, task](){
    // 启动连接状态的监视器
    zmq_socket_monitor(_socket, ZMQ_MONITOR_ADDR, ZMQ_EVENT_CONNECTED | ZMQ_EVENT_DISCONNECTED);
    // 创建监视器套接字
    _monitor = zmq::socket_t(_ctx, ZMQ_PAIR);
    _monitor.connect(ZMQ_MONITOR_ADDR);

    while (true)
    {
      // 检查套接字是否有可读事件
      zmq::pollitem_t items[] = {
          {static_cast<void *>(_socket), 0, ZMQ_POLLIN, 0},
          {static_cast<void *>(_monitor), 0, ZMQ_POLLIN, 0},
      };
      zmq::poll(items, 2, std::chrono::milliseconds{-1});
      // 检查监视器套接字是否有可读事件
      if (items[1].revents & ZMQ_POLLIN)
      {
        // 读取事件
        zmq_msg_t msg;
        zmq_msg_init(&msg);
        zmq_msg_recv(&msg, _monitor, 0);

        // 解析事件
        auto* evt_msg = static_cast<zmq_event_t*>(zmq_msg_data(&msg));
        if (evt_msg->event == ZMQ_EVENT_CONNECTED)
        {
          SDBG << "Connected to the server.";
        }
        else if (evt_msg->event == ZMQ_EVENT_DISCONNECTED)
        {
          SDBG << "Disconnected from the server.";
          if (task)
          {
            task();
          }
          else
          {
            SERROR << "task is not called";
          }
        }
        zmq_msg_close(&msg);
      }
    }
  });
  if (monitor_thread.joinable())
  {
    monitor_thread.detach();
  }
}

std::string TcpClient::send(const std::string& data)
{
  zmq::message_t msg(data.size());
  memcpy(msg.data(), data.c_str(), data.size());
  auto ok = _socket.send(msg, zmq::send_flags::none);
  if (!ok) {
    SERROR << "send data with error";
    return nullptr;
  }

  zmq::message_t reply;
  auto result = _socket.recv(reply, zmq::recv_flags::none);
  result = result;
  std::string result_str(static_cast<const char*>(reply.data()), reply.size());
  return result_str;
}

Subscriber::Subscriber(std::string url) : _url(url), _ctx(1)
{
  this->connect();
}

Subscriber::~Subscriber() {}

void Subscriber::connect()
{
  _socket = zmq::socket_t(_ctx, ZMQ_SUB);
  _socket.connect(_url);
  if (_socket.handle() == nullptr) { SFATAL << "connect server with error" << _url; }
  SINFO << "Subscriber connect ok " << _url;
  {
    //去警告
    zmq_setsockopt(_socket.handle(), ZMQ_SUBSCRIBE, nullptr, 0);
    //_socket.setsockopt(ZMQ_SUBSCRIBE, nullptr, 0);
  }
}

void Subscriber::run()
{
  while (!this->_stop) {
    zmq::message_t request;
    auto ok = this->_socket.recv(request, zmq::recv_flags::none);
    if (ok) {
      const std::string str = std::string(static_cast<const char*>(request.data()), request.size());
      onRecv(str);
    }
    else {
      onError(RespInterface::ERROR_NET_RECV);
    }
  }
}

Subscriber::Ptr Subscriber::start(std::string url, RespInterface::Ptr listener)
{
  auto subscriber = std::make_shared<Subscriber>(url);

  std::weak_ptr<Subscriber> weak_ptr = subscriber;
  std::thread([weak_ptr]() {
    auto strong = weak_ptr.lock();
    if (strong) { strong->run(); }
  }).detach();
  return subscriber;
}