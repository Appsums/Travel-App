//
//  QBRequest+QBContent.h
//  Quickblox
//
//  Created by QuickBlox team on 6/5/14.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import "QBRequest.h"

@class QBCBlob;
@class QBCBlobObjectAccess;
@class QBGeneralResponsePage;

NS_ASSUME_NONNULL_BEGIN

typedef void(^qb_response_blob_block_t)(QBResponse *response, QBCBlob *tBlob);

@interface QBRequest (QBContent)


//MARK: - Get Blob with ID

/**
 Retrieve blob with ID.
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)blobWithID:(NSUInteger)blobID
             successBlock:(nullable qb_response_blob_block_t)successBlock
               errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Get list of blobs for the current user

/**
 Get list of blob for the current User (with extended set of pagination parameters)
 
 @param page Page information
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)blobsForPage:(nullable QBGeneralResponsePage *)page
               successBlock:(nullable void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray<QBCBlob *> * blobs))successBlock
                 errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Update Blob

/**
 Update Blob
 
 @param blob An instance of QBCBlob to be updated.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateBlob:(QBCBlob *)blob
             successBlock:(nullable qb_response_blob_block_t)successBlock
               errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Delete Blob with ID

/**
 Delete Blob
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteBlobWithID:(NSUInteger)blobID
                   successBlock:(nullable qb_response_block_t)successBlock
                     errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Get File by ID as BlobObjectAccess

/**
 Get File by ID as BlobObjectAccess with read access
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)blobObjectAccessWithBlobID:(NSUInteger)blobID
                             successBlock:(nullable void(^)(QBResponse *response, QBCBlobObjectAccess *objectAccess))successBlock
                               errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Upload file using BlobObjectAccess

/**
 Upload file using BlobObjectAccess
 
 @param data File
 @param blobWithWriteAccess An instance of QBCBlobObjectAccess
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)uploadFile:(nullable NSData *)data
      blobWithWriteAccess:(QBCBlob *)blobWithWriteAccess
             successBlock:(nullable qb_response_block_t)successBlock
              statusBlock:(nullable qb_response_status_block_t)statusBlock
               errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: -  Download file

/**
 Download file
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)downloadFileWithUID:(NSString *)UID
                      successBlock:(nullable void(^)(QBResponse *response, NSData *fileData))successBlock
                       statusBlock:(nullable qb_response_status_block_t)statusBlock
                        errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Download file using background NSURLSession.
 
 @discussion If download is triggered by 'content-available' push - blocks will not be fired.
 
 @param UID File unique identifier, value of UID property of the QBCBlob instance.
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)backgroundDownloadFileWithUID:(NSString *)UID
                                successBlock:(nullable void(^)(QBResponse *response, NSData *fileData))successBlock
                                 statusBlock:(nullable qb_response_status_block_t)statusBlock
                                  errorBlock:(nullable qb_response_block_t)errorBlock;
/**
 Download File by file identifier.
 
 @param fileID File identifier.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)downloadFileWithID:(NSUInteger)fileID
                     successBlock:(nullable void(^)(QBResponse *response, NSData *fileData))successBlock
                      statusBlock:(nullable qb_response_status_block_t)statusBlock
                       errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Download File by file identifier using background NSURLSession.
 
 @discussion If download is triggered by 'content-available' push - blocks will not be fired.
 
 @param fileID File identifier.
 @param successBlock Block with response and fileData if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)backgroundDownloadFileWithID:(NSUInteger)fileID
                               successBlock:(nullable void(^)(QBResponse *response, NSData *fileData))successBlock
                                statusBlock:(nullable qb_response_status_block_t)statusBlock
                                 errorBlock:(nullable qb_response_block_t)errorBlock;
//MARK: - Tasks

/**
 Upload File task. Contains 3 requests: Create Blob, upload file, declaring file uploaded
 
 @param data File to be uploaded
 @param fileName Name of the file
 @param contentType Type of the content in mime format
 @param isPublic Blob's visibility
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)TUploadFile:(NSData *)data
                  fileName:(NSString *)fileName
               contentType:(NSString *)contentType
                  isPublic:(BOOL)isPublic
              successBlock:(nullable qb_response_blob_block_t)successBlock
               statusBlock:(nullable qb_response_status_block_t)statusBlock
                errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 Upload File task. Contains 3 requests: Create Blob, upload file, declaring file uploaded
 
 @param url File url to be uploaded
 @param fileName Name of the file
 @param contentType Type of the content in mime format
 @param isPublic Blob's visibility
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)uploadFileWithUrl:(NSURL *)url
                        fileName:(NSString *)fileName
                     contentType:(NSString *)contentType
                        isPublic:(BOOL)isPublic
                    successBlock:(nullable qb_response_blob_block_t)successBlock
                     statusBlock:(nullable qb_response_status_block_t)statusBlock
                      errorBlock:(nullable qb_response_block_t)errorBlock;
/**
 Update File task. Contains 3 quieries: Update Blob, Upload file, Declaring file uploaded
 
 @param data File to be uploaded
 @param file File which needs to be updated
 @param successBlock Block with response if request succeded
 @param statusBlock Block with upload/download progress
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)TUpdateFileWithData:(NSData *)data
                              file:(QBCBlob *)file
                      successBlock:(nullable qb_response_block_t)successBlock
                       statusBlock:(nullable qb_response_status_block_t)statusBlock
                        errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: DEPRECATED

/**
 Get list of blob for the current User (last 10 files)
 
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)blobsWithSuccessBlock:(nullable void(^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray<QBCBlob *> * _Nullable blobs))successBlock
                          errorBlock:(nullable qb_response_block_t)errorBlock
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.10 Use 'blobsForPage:successBlock:errorBlock:'.");


/**
 Get list of tagged blobs for the current User (last 10 files)
 
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)taggedBlobsWithSuccessBlock:(nullable void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray<QBCBlob *> * _Nullable blobs))successBlock
                                errorBlock:(nullable qb_response_block_t)errorBlock
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.10 Use 'taggedBlobsForPage:successBlock:errorBlock:'.");

//MARK: - Get list of tagged blobs for the current user

/**
 Get list of tagged blobs for the current User (with extended set of pagination parameters)
 
 @param page Page information
 @param successBlock Block with response, page and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)taggedBlobsForPage:(nullable QBGeneralResponsePage *)page
                     successBlock:(nullable void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray<QBCBlob *> *blobs))successBlock
                       errorBlock:(nullable qb_response_block_t)errorBlock DEPRECATED_ATTRIBUTE;


//MARK: - Create Blob

/**
 Create blob.
 
 @param blob An instance of QBCBlob, describing the file to be uploaded.
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createBlob:(QBCBlob *)blob
             successBlock:(nullable qb_response_blob_block_t)successBlock
               errorBlock:(nullable qb_response_block_t)errorBlock DEPRECATED_ATTRIBUTE;

//MARK: - Declaring Blob uploaded with ID

/**
 Declaring Blob uploaded with ID
 
 @param blobID Unique blob identifier, value of ID property of the QBCBlob instance.
 @param size Size of uploaded file, in bytes
 @param successBlock Block with response and blob instances if request succeded
 @param errorBlock Block with response instance if request failed
 
 @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)completeBlobWithID:(NSUInteger)blobID
                             size:(NSUInteger)size
                     successBlock:(nullable qb_response_block_t)successBlock
                       errorBlock:(nullable qb_response_block_t)errorBlock DEPRECATED_ATTRIBUTE;

@end

NS_ASSUME_NONNULL_END
