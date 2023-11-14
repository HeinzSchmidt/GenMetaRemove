import os
import logging
import uuid
from PIL import Image
import boto3
import botocore
import urllib.parse

# Fetch Environment Variables
TARGET_BUCKET = os.environ.get('bucket_outbox')
BUCKET_REGION = os.environ.get('REGION')

S3 = boto3.resource('s3')
s3_client = boto3.client('s3')

# Logging
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

# Image exif clean function
def clean_image_exif(downloadPath, uploadPath):

    try:
        # load the image
        dirty_image = Image.open(downloadPath)
        # strip the exif
        image_data = list(dirty_image.getdata())
        image_without_exif = Image.new(dirty_image.mode, dirty_image.size)
        image_without_exif.putdata(image_data)
        # save the image
        image_without_exif.save(uploadPath)

    except Exception as error:
            LOGGER.error(error)
            LOGGER.error('Error resizing source image from {} and saving to {}.'.format(downloadPath, uploadPath))
            raise error

# Main function
def lambda_handler(event, context):

    LOGGER.info('Event structure: %s', event)
    LOGGER.info('DST_BUCKET: %s', TARGET_BUCKET)

    # Iterate the event list
    for record in event['Records']:

        try:
            # Get the bucket and jpg image from the event record
            source_bucket = record['s3']['bucket']['name']
            source_key = urllib.parse.unquote_plus(record['s3']['object']['key'], encoding='utf-8')

            # Remove the EXIF metadata
            download_path = '/tmp/{}{}'.format(uuid.uuid4(), source_key)
            upload_path = '/tmp/clean-{}'.format(source_key)

            s3_client.download_file(source_bucket, source_key, download_path)
            clean_image_exif(download_path, upload_path)
            s3_client.upload_file(upload_path, TARGET_BUCKET, source_key)

            LOGGER.info("File copied to the destination bucket successfully!")
            
        except botocore.exceptions.ClientError as error:
            LOGGER.error("There was an error copying the file to the destination bucket")
            print('Error Message: {}'.format(error))
            
        except botocore.exceptions.ParamValidationError as error:
            LOGGER.error("Missing required parameters while calling the API.")
            print('Error Message: {}'.format(error))

        except Exception as error:
            LOGGER.error(error)
            LOGGER.error('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(source_key, source_bucket))
            raise error
        
        return {
            'status': 'ok'
        }
              
