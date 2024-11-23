import time
import os
import pyzipper
import tarfile
import requests
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class DirectoryObserver:
    def __init__(self, observer, directory_path):
        self.directory_path = directory_path
        self.observer = observer
        
    def start(self):
        self.event_handler = NewFileHandler()
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
    def on_created(self, event):
        if not event.is_directory:
            try:      
                while os.path.getsize(event.src_path) == 0:
                    time.sleep(0.1)

                decompressor = Decompressor()
                scheduler = Scheduler()
                new_decompressed_content = decompressor.decompress(event.src_path)

                if new_decompressed_content: 	
                    if not isinstance(new_decompressed_content, list):
                        schedule_response = scheduler.schedule_analysis(new_decompressed_content)
                        print("Task ID: ", schedule_response)
                        
            except Exception as e:
                print(f"Error: {e}")
            
class Decompressor:
    def __init__(self, password_file='password.txt'):
        self.script_directory = os.path.dirname(os.path.abspath(__file__))
        self.password_file = os.path.join(self.script_directory, password_file)
        self.MAGIC_BYTES = {
            b'\x50\x4B\x03\x04': 'ZIP',               # ZIP files
            b'\x1F\x8B': 'GZIP',                      # GZIP files
            b'\x75\x73\x74\x61\x72': 'TAR',           # TAR files
            b'\x62\x5A': 'BZ2',                       # BZ2 files
        }

    def filetype_identification(self, filepath):
        """
        Identifies the file type based on its magic bytes
        """
        with open(filepath, 'rb') as file:
            magic_bytes_read = file.read(max(len(header) for header in self.MAGIC_BYTES))
            for header, filetype in self.MAGIC_BYTES.items():
                if magic_bytes_read.startswith(header):
                    return filetype
        return None

    def decompress_mapper(self):
        """
        Based on the file extension, returns the corresponding method to use for decompression
        """
        return {
            'ZIP': self.decompress_zip_files,
            'TAR': self.decompress_tar_files,
            'GZIP': self.decompress_tar_files,
            'BZ2': self.decompress_tar_files,
        }

    def decompress_zip_files(self, filepath, destination):
        """
        Decompresses or extracts ZIP files
        """
        extracted_files = []
        with pyzipper.AESZipFile(filepath, 'r') as zip_archive:
            if any(file_info.flag_bits & 0x1 for file_info in zip_archive.infolist()):
                with open(self.password_file, 'r') as pf:
                    for line in pf:
                        password = line.strip().encode('utf-8')
                        try:
                            zip_archive.setpassword(password)
                            zip_archive.extractall(destination)
                            return zip_archive.namelist()
                        except RuntimeError:
                            continue
            else:
                zip_archive.extractall(destination)
                return zip_archive.namelist()
        
        return None

    def decompress_tar_files(self, filepath, destination):
        """
        Decompresses TAR files
        """
        with tarfile.open(filepath, 'r:*') as tar_archive:
            tar_archive.extractall(destination)
            return tar_archive.getnames()

    def decompress(self, filepath):
        """
        Main decompress function
        """
        filetype = self.filetype_identification(filepath)
        if not filetype: # If file is not even archived in the first place
            return filepath

        else:
            decompress_function = self.decompress_mapper().get(filetype)
            destination = os.path.dirname(filepath)

            if decompress_function:
                extracted_files = decompress_function(filepath, destination)
                os.remove(filepath)

                if extracted_files:
                    return extracted_files
                return None

class Scheduler:
    def __init__(self):
        self.url = "http://localhost:8000/apiv2/tasks/create/file/"
    
    def schedule_analysis(self, filepath):
        file = {'file': open(filepath, 'rb')}
        data = {
            'timeout':900,
            'machine':'win10clone4', 
            'options':'bp0=ep'
        }

        response = requests.post(self.url, files=file, data=data)
        task_id = response.json()['data']['task_ids'][0]
        return task_id

if __name__ == "__main__":
    directory_to_monitor = "/home/cape/automation"
    observer_instance = Observer()
    observer = DirectoryObserver(observer_instance, directory_to_monitor)
    observer.start()