#!/bin/bash
# Собирает Release и копирует всё нужное в папку deploy/

QT_DIR="/home/ualdrm/Qt/6.10.3/gcc_64"
BUILD_DIR="/home/ualdrm/QtProjects/AlinaRE/build/Desktop_Qt_6_10_3-u0412u044bu043fu0443u0441u043a"
DEPLOY_DIR="/home/ualdrm/QtProjects/AlinaRE/deploy"

mkdir -p "$DEPLOY_DIR"

# Копируем бинарник
cp "$BUILD_DIR/appAlinaRE" "$DEPLOY_DIR/"

# Копируем Qt библиотеки
for lib in Qt6Core Qt6Gui Qt6Quick Qt6Qml Qt6Network Qt6Multimedia Qt6MultimediaQuick Qt6OpenGL Qt6QmlModels Qt6QmlWorkerScript; do
    cp "$QT_DIR/lib/lib${lib}.so.6" "$DEPLOY_DIR/" 2>/dev/null && echo "✓ $lib" || echo "✗ $lib (не найдена)"
done

# Копируем QML модули
mkdir -p "$DEPLOY_DIR/qml"
cp -r "$QT_DIR/qml/QtQuick"        "$DEPLOY_DIR/qml/" 2>/dev/null
cp -r "$QT_DIR/qml/QtQuick.2"     "$DEPLOY_DIR/qml/" 2>/dev/null
cp -r "$QT_DIR/qml/QtQml"         "$DEPLOY_DIR/qml/" 2>/dev/null
cp -r "$QT_DIR/qml/QtMultimedia"  "$DEPLOY_DIR/qml/" 2>/dev/null

# Скрипт запуска
cat > "$DEPLOY_DIR/run.sh" << 'EOF'
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
export LD_LIBRARY_PATH="$DIR:$LD_LIBRARY_PATH"
export QML2_IMPORT_PATH="$DIR/qml"
"$DIR/appAlinaRE"
EOF
chmod +x "$DEPLOY_DIR/run.sh"

echo ""
echo "✅ Готово! Папка: $DEPLOY_DIR"
echo "   Запуск: $DEPLOY_DIR/run.sh"
echo "   Для архива: tar -czf SudokuRE.tar.gz -C $(dirname $DEPLOY_DIR) deploy"
