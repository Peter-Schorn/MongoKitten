import Foundation

/// A GridFS file that can be downloaded from GridFS or uploaded to GridFS.
public struct GridFSFile: Codable {
    internal var fs: GridFSBucket
    
    /// The file's ID
    public let _id: Primitive

    /// The file's length in bytes
    public internal(set) var length: Int

    /// The chunk size in bytes
    public private(set) var chunkSize: Int32

    /// The date this file was uploaded
    public let uploadDate: Date

    /// The MD5 hash of this file.
    public internal(set) var md5: String?

    /// The filename of this file as it was uploaded.
    public var filename: String?
    
    @available(*, deprecated, message: "Applications wishing to store a contentType should add a contentType field to the metadata document instead.")
    public var contentType: String? {
        get {
            return _contentType
        }
        set {
            _contentType = newValue
        }
    }
    
    /// We use the getters and setters so we can decode and encode the contentType without warnings, while providing a deprecation warning to users trying to use the property
    private var _contentType: String?
    
    @available(*, deprecated, message: "Applications wishing to store aliases should add an aliases field to the metadata document instead.")
    public var aliasses: [String]? {
        get {
            return _aliasses
        }
        set {
            _aliasses = newValue
        }
    }
    
    /// We use the getters and setters so we can decode and encode the aliasses without warnings, while providing a deprecation warning to users trying to use the property
    private var _aliasses: [String]?
    
    /// The metadata of this file, to be used by applications. This is not used by GridFS itself.
    public var metadata: Document?
    
    internal init(id: Primitive, length: Int, chunkSize: Int32, metadata: Document?, filename: String?, fs: GridFSBucket) {
        self._id = id
        self.length = length
        self.chunkSize = chunkSize
        self.metadata = metadata
        self.filename = filename
        self.fs = fs
        self.uploadDate = Date()
    }
    
    private enum CodingKeys: String, CodingKey {
        case _id, length, chunkSize, uploadDate, md5, filename, contentType, aliasses, metadata
    }
    
    /// The reader for this file that can be used to download the file
    public var reader: GridFSReader {
        return GridFSReader(file: self)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let userInfo = decoder.userInfo
        guard let fs = userInfo[.gridFS] as? GridFSBucket else {
            throw GridFSError.missingGridFSUserInfo
        }
        
        self.fs = fs
        self._id = try container.decode(Primitive.self, forKey: ._id)
        self.length = try container.decode(Int.self, forKey: .length)
        self.chunkSize = try container.decode(Int32.self, forKey: .chunkSize)
        self.uploadDate = try container.decode(Date.self, forKey: .uploadDate)
        self.md5 = try container.decodeIfPresent(String.self, forKey: .md5)
        self.filename = try container.decodeIfPresent(String.self, forKey: .filename)
        self._contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
        self._aliasses = try container.decodeIfPresent([String].self, forKey: .aliasses)
        self.metadata = try container.decodeIfPresent(Document.self, forKey: .metadata)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeBSONPrimitive(self._id, forKey: ._id)
        try container.encode(self.length, forKey: .length)
        try container.encode(self.chunkSize, forKey: .chunkSize)
        try container.encode(self.uploadDate, forKey: .uploadDate)
        try container.encode(self.md5, forKey: .md5)
        try container.encode(self.filename, forKey: .filename)
        try container.encode(self._contentType, forKey: .contentType)
        try container.encode(self._aliasses, forKey: .aliasses)
        try container.encodeBSONPrimitive(self.metadata, forKey: .metadata)
    }
    
}
