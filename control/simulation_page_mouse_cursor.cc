#include "simulation_page_mouse_cursor.h"

Simulation_page_mouse_cursor::Simulation_page_mouse_cursor() {}
Simulation_page_mouse_cursor::~Simulation_page_mouse_cursor() {}
void Simulation_page_mouse_cursor::setMyCursor(QObject* obj_mouse,
                                               QString image_source, int width,
                                               int height) {
  if (nullptr == obj_mouse) {
    return;
  }
  // 需要将 Qml对象转换为 QQuickItem对象才能 setCursor()
  QQuickItem* itemObj = qobject_cast<QQuickItem*>(obj_mouse);
  if (nullptr == obj_mouse) {
    return;
  }
  //示例
  // itemObj->setCursor(QCursor(QPixmap(":///resource/image/simulation_page/car.png")));
  itemObj->setCursor(QCursor(
      QPixmap(image_source).scaled(width, height)));  //, Qt::KeepAspectRatio
}