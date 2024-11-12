#Ensure that zipfile, tarfile, requests and watchdog libaries are installed
#Ensure that password.txt exists if the zip file you intend to copy in consists of a password
#Ensure that the password can be found in password.txt when extracting Password-Protected zip files

import time
import os
import zipfile
import tarfile
import requests
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class DirectoryObserver:
    def __init__(self, directory_path):
        self.directory_path = directory_path
        self.observer = Observer()
        
    def start(self):
        decompressor = Decompressor()
        self.event_handler = NewFileHandler(decompressor)
        self.observer.schedule(self.event_handler, self.directory_path, recursive=False)
        self.observer.start()
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            self.stop()

    def stop(self):
        self.observer.stop()
        self.observer.join()
        
class NewFileHandler(FileSystemEventHandler):
    def __init__(self, decompressor):
        super().__init__()
        self.decompressor = decompressor

    def on_created(self, event):
        if not event.is_directory:
            while os.path.getsize(event.src_path) == 0:
            	time.sleep(0.1)
            	
            executable_detected = self.decompressor.decompress(event.src_path)
            scheduler = Scheduler()

            if executable_detected:
               schedule_response = scheduler.schedule_analysis(executable_detected)
               print("Task ID: ", schedule_response)
            
class Decompressor:
    def __init__(self):
        self.MAGIC_BYTES = {
            b'\x50\x4B\x03\x04': 'ZIP',               # ZIP files
            b'\x1F\x8B': 'GZIP',                      # GZIP files
            b'\x52\x61\x72\x21\x1A\x07\x00': 'RAR',   # RAR files
            b'\x75\x73\x74\x61\x72': 'TAR',           # TAR files
            b'\x62\x5A': 'BZ2',                       # BZ2 files
            b'\xFD\x37\x7A\x58\x5A\x00': 'XZ'         # XZ files
        }
    
    def identify_file_type(self, filepath):
        with open(filepath, 'rb') as file:
            magic_bytes_read = file.read(8)
            for header, filetype in self.MAGIC_BYTES.items():
                if magic_bytes_read.startswith(header):
                    return filetype
        return None

    def decompress_zip_files(self, filepath, destination):
        script_dir = os.path.dirname(os.path.abspath(__file__))
        password_file = os.path.join(script_dir, 'password.txt')
        with zipfile.ZipFile(filepath, 'r') as zip_archive:
            if any(file_info.flag_bits & 0x1 for file_info in zip_archive.infolist()):
                with open(password_file, 'r') as pf:
                    for line in pf:
                        password = line.strip().encode('utf-8')
                        try:
                            zip_archive.extractall(destination, pwd=password)
                            return zip_archive.namelist()
                        except (RuntimeError, zipfile.BadZipFile):
                            continue
            else:
                zip_archive.extractall(destination)
                return zip_archive.namelist()


    def decompress_tar_files(self, filepath, destination):
        with tarfile.open(filepath, 'r:*') as tar_archive:
            tar_archive.extractall(destination)
            return tar_archive.getnames()

    def decompress_mapper(self, filetype):
        return {
            'ZIP': self.decompress_zip_files,
            'TAR': self.decompress_tar_files,
            'GZIP': self.decompress_tar_files,
            'BZ2': self.decompress_tar_files,
            'XZ': self.decompress_tar_files
        }.get(filetype)

    def decompress(self, filepath):
        extension = self.identify_file_type(filepath)
        destination = os.path.dirname(filepath)
        relevant_decompress_function = self.decompress_mapper(extension)

        if relevant_decompress_function:
            extracted_files = relevant_decompress_function(filepath, destination)
            os.remove(filepath)

            for filename in extracted_files:
                if filename.endswith(".txt"):
                    executable = os.path.join(destination, filename)
                    return executable
        return None 

class Scheduler:
    def __init__(self):
        self.url = "http://localhost:8000/apiv2/tasks/create/file/"
    
    def schedule_analysis(self, filepath):
        file = {'file': open(filepath, 'rb')}
        data = {
            'timeout':900,
            'machine':'win10clone4' 
        }

        response = requests.post(self.url, files=file, data=data)
        task_id = response.json()['data']['task_ids'][0]
        return task_id

if __name__ == "__main__":
    directory_to_monitor = "/home/cape/automation"
    observer = DirectoryObserver(directory_to_monitor)
    observer.start()
	