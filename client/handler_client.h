/*
 * Copyright 2012-2022
 * All rights reserved.
 */

#ifndef CLIENT_HANDLER_HEADER_
#define CLIENT_HANDLER_HEADER_

#include <memory>
#include <mutex>

#include "client/context.h"
#include "client/logger.h"

class HandlerClient : public RespInterface {
 public:
  using func_task = std::function<void()>;
  HandlerClient() { context_.setRespInterface(this); }
  virtual ~HandlerClient() = default;

  std::string request(const std::string& request) {
    return context_.send(request);
  }

  virtual void onRecv(const std::string& data) {
    SINFO << "HandlerClient onRecv " << data;
  }
  virtual void onError(Errno err) { SINFO << "HandlerClient onError " << err; }

 protected:
  void set_socket_listener(const func_task& task) {
    context_.setSocketListener(task); 
  }

 protected:
  Context context_;
};

#endif