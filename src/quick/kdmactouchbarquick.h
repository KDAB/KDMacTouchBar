/****************************************************************************
** Copyright (C) 2019-2023 Klarälvdalens Datakonsult AB, a KDAB Group company, info@kdab.com.
** All rights reserved.
**
** This file is part of the KD MacTouchBar library.
**
** This file may be distributed and/or modified under the terms of the
** GNU Lesser General Public License version 3 as published by the
** Free Software Foundation and appearing in the file LICENSE.LGPL.txt included.
**
** You may even contact us at info@kdab.com for different licensing options.
**
** This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
** WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
**
** Contact info@kdab.com if any conditions of this licensing are not
** clear to you.
**
**********************************************************************/

#ifndef KDMACTOUCHBARQUICK_H
#define KDMACTOUCHBARQUICK_H

#include "kdmactouchbar_global.h"

#include <QtQuick/QQuickItem>

QT_BEGIN_NAMESPACE

class TouchBar : public QQuickItem {
  Q_OBJECT
  Q_PROPERTY(bool global READ isGlobal WRITE setGlobal NOTIFY globalChanged)
  Q_PROPERTY(QQuickItem *escapeItem READ escapeItem WRITE setEscapeItem NOTIFY escapeItemChanged)
public:
  explicit TouchBar(QQuickItem *parent = nullptr);
  ~TouchBar() override;

  static int registerQmlType();

  bool isGlobal() const;
  void setGlobal(bool global);

  QQuickItem *escapeItem() const;
  void setEscapeItem(QQuickItem *escapeItem);

  bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
  void globalChanged(bool global);
  void escapeItemChanged(QQuickItem* esacpeItem);

protected:
  void itemChange(ItemChange change, const ItemChangeData &value) override;

private:
  void *m_tbProvider;
  bool m_global = true;
  QQuickItem *m_escapeItem = nullptr;
};

QT_END_NAMESPACE

#endif
