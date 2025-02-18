import os
import re

def check_files(directory, suspicious_words):
    """Проверяет файлы в указанном каталоге на наличие подозрительных слов."""
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            ext = os.path.splitext(filename)[1].lower()
            if ext == ".bat" or ext == ".txt":
                try:
                    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read().lower()
                        for word in suspicious_words:
                            if re.search(r'\b' + re.escape(word) + r'\b', content):
                                print(f"Подозрительный файл найден: {filename}. Содержит слово: {word}")
                                try:
                                    os.remove(filepath)
                                    print(f"Файл '{filename}' удален.")
                                except OSError as e:
                                    print(f"Ошибка при удалении файла '{filename}': {e}")
                                break
                except (UnicodeDecodeError, OSError) as e:
                    print(f"Ошибка при обработке файла {filename}: {e}")


if __name__ == "__main__":
    suspicious_words = ["/start", "cmd", "powershell", "del", "format", "shutdown", "attrib +h +s", "reg add", "copy", "type"]

    # Замените на путь к нужной папке
    target_directory = "C:\\Users\\DaYaRusskiy\\Desktop"  #Убедитесь что путь указан верно!

    try:
        check_files(target_directory, suspicious_words)
    except FileNotFoundError:
        print(f"Директория '{target_directory}' не найдена.")
    except Exception as e:
        print(f"Произошла ошибка: {e}")

