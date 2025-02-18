import time
import os
import re
import wmi

def get_drive_letter():
    """Возвращает букву диска, соответствующую съемному диску."""
    c = wmi.WMI()
    for drive in c.Win32_LogicalDisk(DriveType=2):  # 2 - съемный диск
        return drive.DeviceID[:-1]  # Удаляем последний символ ":"
    return None

def check_files(directory, suspicious_words):
    """Проверяет файлы в указанном каталоге на наличие подозрительных слов."""
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            ext = os.path.splitext(filename)[1].lower()
            if ext in [".bat", ".txt", ".vbs"]:
                # Открываем файл и проверяем его содержимое
                try:
                    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read().lower()  # Читаем содержимое файла
                except (UnicodeDecodeError, OSError) as e:
                    print(f"Ошибка при обработке файла {filename}: {e}")
                    continue  # Переходим к следующему файлу, если произошла ошибка
                
                # Проверяем на наличие подозрительных слов
                for word in suspicious_words:
                    if re.search(r'\b' + re.escape(word) + r'\b', content):
                        print(f"Подозрительный файл найден: {filename}. Содержит слово: {word}")
                        for attempt in range(3):  # Попробовать удалить файл 3 раза
                            try:
                                os.remove(filepath)
                                print(f"Файл '{filename}' удален.")
                                break  # Успешное удаление, выходим из цикла
                            except OSError as e:
                                if attempt < 2:  # Если это не последняя попытка
                                    print(f"Ошибка при удалении файла '{filename}': {e}. Повторная попытка через 1 секунду...")
                                    time.sleep(1)  # Задержка перед повторной попыткой
                                else:
                                    print(f"Не удалось удалить файл '{filename}' после 3 попыток.")
                        break  # Если нашли подозрительное слово, выходим из цикла проверки слов

if __name__ == "__main__":
    suspicious_words = ["/start", "/del", "cmd", "powershell", "del", "format", "shutdown", "attrib +h +s", "reg add", "copy", "type"]

    while True:
        drive_letter = get_drive_letter()

        if drive_letter:
            print(f"Найдена съемная флешка на диске: {drive_letter}:")
            try:
                check_files(drive_letter + ":\\", suspicious_words)
            except FileNotFoundError:
                print(f"Каталог '{drive_letter}:\\' не найден.")
            except Exception as e:
                print(f"Произошла ошибка: {e}")
        else:
            print("Съемная флешка не найдена.")

        time.sleep(5)  # Задержка перед следующей проверкой (например, 5 секунд)
