//
//  AmazonProduct.swift
//  SidebarMenu
//
//  Created by Hai Nguyen on 2/3/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import Alamofire
import Foundation
import SHXMLParser

enum AmazonProductAdvertising: String {
    case StandardRegion = "webservices.amazon.com"
    case AWSAccessKey = "AWSAccessKeyId"
    case TimestampKey = "Timestamp"
    case SignatureKey = "Signature"
    case VersionKey = "Version"
    case AssociateTagKey = "AssociateTag"
    case CurrentVersion = "2016-02-04"
}

let AWSDateISO8601DateFormat3 = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"
//"yyyy-MM-dd'T'HH:mm:ss.'ZZZZSZ'"
let associate_tag_default = "amazsellassi-20"
let aws_key_default = "AKIAJQ2R7LH55E5E7GBA"
let aws_secret_default = "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"

func amazonRequest(parameters: [String: AnyObject]? = nil, serializer ser: AmazonSerializer?) -> Alamofire.Request {
    
    let serializer: AmazonSerializer = {
        if let s = ser {
            return s
        } else {
            let s = AmazonSerializer(key: aws_key_default, secret: aws_secret_default)
            s.useSSL = false
            return s
        }
    }()
    
    let URL = serializer.endpointURL()
    
    let e = Alamofire.ParameterEncoding.Custom(serializer.serializerBlock())
    
    let mutableURLRequest = NSMutableURLRequest(URL: URL)
    
    mutableURLRequest.HTTPMethod = Alamofire.Method.GET.rawValue
    
    let encoded: URLRequestConvertible  = e.encode(mutableURLRequest, parameters: parameters).0
    
    return Alamofire.request(encoded)
}

class AmazonSerializer {
    
    let accessKey: String
    let secret: String
    
    var region: String = AmazonProductAdvertising.StandardRegion.rawValue
    var formatPath: String = "/onca/xml"
    var useSSL = true
    
    init(key: String, secret sec: String) {
        self.secret = sec
        self.accessKey = key
    }
    
    func endpointURL() -> NSURL {
        //somehow https doesnt work so i make it http
        let scheme = useSSL ? "http" : "http"
        let URL = NSURL(string: "\(scheme)://\(region)\(formatPath)")
        return URL!
    }
    
    func serializerBlock() -> (URLRequestConvertible, [String: AnyObject]?) -> (NSMutableURLRequest, NSError?) {
        return { (req, params) -> (NSMutableURLRequest, NSError?) in
            
            // TODO: if params == nil error out ASAP
            
            var mutableParameters = params!
            
            let timestamp = AmazonSerializer.ISO8601FormatStringFromDate(NSDate())
            
            if mutableParameters[AmazonProductAdvertising.AWSAccessKey.rawValue] == nil {
                mutableParameters[AmazonProductAdvertising.AWSAccessKey.rawValue] = self.accessKey
            }

            mutableParameters[AmazonProductAdvertising.TimestampKey.rawValue] = timestamp;
            
            var canonicalStringArray = [String]()
            
            // alphabetize
            let sortedKeys = Array(mutableParameters.keys).sort {$0 < $1}
            
            for key in sortedKeys {
                canonicalStringArray.append("\(key)=\(mutableParameters[key]!)")
            }
            
            let canonicalString = canonicalStringArray.joinWithSeparator("&")
            
            let encodedCanonicalString = CFURLCreateStringByAddingPercentEscapes(
                nil,
                canonicalString,
                nil,
                ":,",//"!*'();:@&=$,/?%#[]",
                CFStringBuiltInEncodings.UTF8.rawValue
            )
            
            let method = req.URLRequest.HTTPMethod
            
            let signature = "\(method)\n\(self.region)\n\(self.formatPath)\n\(encodedCanonicalString)"
            
            print("SIGNATURE== \(signature)")
            
            let encodedSignatureData = signature.hmacSHA256(self.secret)
            var encodedSignatureString = encodedSignatureData.base64EncodedString()
                        
            encodedSignatureString = CFURLCreateStringByAddingPercentEscapes(
                nil,
                encodedSignatureString,
                nil,
                "=",//"!*'();:@&=$,/?%#[]",
                CFStringBuiltInEncodings.UTF8.rawValue
                ) as String
            encodedSignatureString = encodedSignatureString.stringByReplacingOccurrencesOfString(
                "+", withString:"%2B",options: NSStringCompareOptions.LiteralSearch, range: nil)

            let newCanonicalString = "\(encodedCanonicalString)&\(AmazonProductAdvertising.SignatureKey.rawValue)=\(encodedSignatureString)"
            
            let absString = req.URLRequest.URL!.absoluteString
            
            let urlString = req.URLRequest.URL?.query != nil ? "\(absString)&\(newCanonicalString)" : "\(absString)?\(newCanonicalString)"
            
            let request = req.URLRequest.mutableCopy() as! NSMutableURLRequest
            request.URL = NSURL(string: urlString)
            print("request= \(request)")
            return (request, nil)
        }
    }
    
    
    private class func ISO8601FormatStringFromDate(date: NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = AWSDateISO8601DateFormat3//"YYYY-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.stringFromDate(date)
    }
    
    
}

// HMAC and base64 helpers

public extension String {
    
    func hmacSHA256(key: String) -> NSData {
        let inputData: NSData = self.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)!
        let keyData: NSData = key.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)!
        
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CCHmac(UInt32(kCCHmacAlgSHA256), keyData.bytes, size_t(keyData.length), inputData.bytes, size_t(inputData.length), result)
        let data = NSData(bytes: result, length: digestLen)
        result.destroy()
        return data
        

    }
    
}

public extension NSData {
    func base64EncodedString() -> String {
        return self.base64EncodedStringWithOptions([.Encoding64CharacterLineLength])
    }
}



//XML ResponseSerializer
extension Request {
    class func XMLResponseSerializer() -> GenericResponseSerializer<Dictionary<String,AnyObject>> {
        
        return GenericResponseSerializer {
            request, response, data in
            
            guard data != nil else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
            }
            
            let parser = SHXMLParser()

            if let document = parser.parseData(data) as? [String: AnyObject] {

                return .Success(document)
            } else {
                let failureReason = "Data could not be serialized. for some unknwon reason"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                print(data)
                return .Failure(data, error as NSError)
            }
            
        }
    }
    
    public func responseXML(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Dictionary<String, AnyObject>?, ErrorType?) -> Void) -> Self {
        let ser = Request.XMLResponseSerializer()
        
        return response(queue: dispatch_get_main_queue(), responseSerializer: ser) {
            req, res, xmlResult in
    
            switch xmlResult {
            case .Failure( _, let err): completionHandler(req, res, nil, err)
            case .Success(let xml): completionHandler(req, res, xml, nil)
            }
            
        }
    }
}
