from extract import extract
from transform import transform
from load import load

if __name__ == '__main__':
    load(transform(extract()))
