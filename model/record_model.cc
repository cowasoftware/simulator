
#include "record_model.h"

#include "client/logger.h"

void RecordModel::onRecvRecord(std::shared_ptr<RPCReplyRecord> record) {
  record_files_.clear();
  for (int i = 0; i < record->files_size(); ++i) {
    record_files_.push_back(QString::fromStdString(record->files(i)));
  }
  begin_time_ = static_cast<qulonglong>(record->begin());
  end_time_ = static_cast<qulonglong>(record->end());
}
