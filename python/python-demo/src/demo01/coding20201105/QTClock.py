# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: QT
@ProjectName: python-demo
@Date: 2020/11/5 10:27
-------------------------------------------------
"""

import PyQt5.QtCore
from PyQt5.QtGui import *
from PyQt5.QtGui import QPainter
from PyQt5.QtWidgets import *


class clockForm(QWidget):
    def __init__(self, parent=None):
        super(clockForm, self).__init__(parent)
        self.setWindowTitle("Clock")
        self.timer = PyQt5.QtCore.QTimer()
        # 设置窗口计时器
        self.timer.timeout.connect(self.update)
        self.timer.start(1000)

    def paintEvent(self, event):
        painter: QPainter = QPainter(self)
        painter.setRenderHint(QPainter.Antialiasing)

        # 设置表盘中的文字字体
        font = QFont("Times", 6)
        fm = QFontMetrics(font)
        fontRect = fm.boundingRect("99")  # 获取绘制字体的矩形范围

        # 分针坐标点
        minPoints = [PyQt5.QtCore.QPointF(50, 25),
                     PyQt5.QtCore.QPointF(48, 50),
                     PyQt5.QtCore.QPointF(52, 50)]

        # 时钟坐标点
        hourPoints = [PyQt5.QtCore.QPointF(50, 35),
                      PyQt5.QtCore.QPointF(48, 50),
                      PyQt5.QtCore.QPointF(52, 50)]

        side = min(self.width(), self.height())
        # 始终处于窗口中心位置显示
        painter.setViewport((self.width() - side) / 2, (self.height() - side) / 2, side, side)
        # 设置QPainter的坐标系统，无论窗体大小如何变化，
        # 窗体左上坐标为(0,0),右下坐标为(100,100),
        # 因此窗体中心坐标为(50,50)
        painter.setWindow(0, 0, 100, 100)

        # 绘制表盘，使用环形渐变色
        niceBlue = QColor(150, 150, 200)
        haloGrident = QRadialGradient(50, 50, 50, 50, 50)
        haloGrident.setColorAt(0.0, PyQt5.QtCore.Qt.lightGray)
        haloGrident.setColorAt(0.5, PyQt5.QtCore.Qt.darkGray)
        haloGrident.setColorAt(0.9, PyQt5.QtCore.Qt.white)
        haloGrident.setColorAt(1.0, niceBlue)
        painter.setBrush(haloGrident)
        painter.setPen(QPen(PyQt5.QtCore.Qt.darkGray, 1))
        painter.drawEllipse(0, 0, 100, 100)

        transform = QTransform()

        # 绘制时钟为0的字，以及刻度
        painter.setPen(QPen(PyQt5.QtCore.Qt.black, 1.5))
        fontRect.moveCenter(PyQt5.QtCore.QPoint(50, 10 + fontRect.height() / 2))
        painter.setFont(font)
        painter.drawLine(50, 2, 50, 8)  #
        painter.drawText(PyQt5.QtCore.QRectF(fontRect), PyQt5.QtCore.Qt.AlignHCenter | PyQt5.QtCore.Qt.AlignTop, "0")

        for i in range(1, 12):
            transform.translate(50, 50)
            transform.rotate(30)
            transform.translate(-50, -50)
            painter.setWorldTransform(transform)
            painter.drawLine(50, 2, 50, 8)
            painter.drawText(PyQt5.QtCore.QRectF(fontRect), PyQt5.QtCore.Qt.AlignHCenter | PyQt5.QtCore.Qt.AlignTop,"%d" % i)

        transform.reset()

        # 绘制分钟刻度线
        painter.setPen(QPen(PyQt5.QtCore.Qt.blue, 1))
        for i in range(1, 60):
            transform.translate(50, 50)
            transform.rotate(6)
            transform.translate(-50, -50)
            if i % 5 != 0:
                painter.setWorldTransform(transform)
                painter.drawLine(50, 2, 50, 5)

        transform.reset()

        # 获取当前时间
        currentTime = PyQt5.QtCore.QTime().currentTime()
        hour = currentTime.hour() if currentTime.hour() < 12 else currentTime.hour() - 12
        minite = currentTime.minute()
        second = currentTime.second()

        # 获取所需旋转角度
        hour_angle = hour * 30.0 + (minite / 60.0) * 30.0
        minite_angle = (minite / 60.0) * 360.0
        second_angle = second * 6.0

        # 时针
        transform.translate(50, 50)
        transform.rotate(hour_angle)
        transform.translate(-50, -50)
        painter.setWorldTransform(transform)
        painter.setPen(PyQt5.QtCore.Qt.NoPen)
        painter.setBrush(QBrush(PyQt5.QtCore.Qt.darkRed))
        painter.drawPolygon(QPolygonF(hourPoints))

        transform.reset()

        # 分针
        transform.translate(50, 50)
        transform.rotate(minite_angle)
        transform.translate(-50, -50)
        painter.setWorldTransform(transform)
        painter.setBrush(QBrush(PyQt5.QtCore.Qt.darkGreen))
        painter.drawPolygon(QPolygonF(minPoints))

        transform.reset()
        # 秒针
        transform.translate(50, 50)
        transform.rotate(second_angle)
        transform.translate(-50, -50)
        painter.setWorldTransform(transform)
        painter.setPen(QPen(PyQt5.QtCore.Qt.darkCyan, 1))
        painter.drawLine(50, 50, 50, 20)


if __name__ == "__main__":
    import sys

    app = QApplication(sys.argv)
    form = clockForm()
    form.show()
    app.exec_()
