#include <QCursor>
#include <QObject>
#include <QPixmap>
#include <QQuickItem>
#include <QString>

class Simulation_page_mouse_cursor : public QObject {
  Q_OBJECT
 public:
  Simulation_page_mouse_cursor();
  ~Simulation_page_mouse_cursor();

  Q_INVOKABLE void setMyCursor(QObject* obj, QString source, int width,
                               int height);
};