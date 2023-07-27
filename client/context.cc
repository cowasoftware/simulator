/*
 * Copyright 2012-2022
 * All rights reserved.
 */

#include "client/context.h"

#include <chrono>
#include <signal.h>
#include <sstream>
#include <unistd.h>

#include "client/logger.h"
#include "config.h"

std::string Context::s_ip_ = "127.0.0.1";
int Context::s_port_ = 10000;

Context::Context()
{
  std::stringstream server_req_reply_url;
  server_req_reply_url << "tcp://" << s_ip_ << ":" << s_port_;
  std::stringstream server_pub_url;
  server_pub_url << "tcp://" << s_ip_ << ":" << (s_port_ + 1);

  _subscriber = Subscriber::start(server_pub_url.str(), nullptr);
  _client = std::make_shared<TcpClient>(server_req_reply_url.str());
}

Context::~Context()
{
  clear();
}

void Context::clear()
{
  if (_subscriber) _subscriber->stop();
  _subscriber = nullptr;
  _client = nullptr;
}
