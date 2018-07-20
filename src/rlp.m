#import "rlp.h"

// spec: https://github.com/ethereum/wiki/wiki/RLP

static size_t rlp_len_length(size_t length) {
    size_t loglen = 1;
    while (length >>= 8) loglen++;
    return loglen;
}

// the length of a buffer that exact fits the rlp encoding of root
static size_t rlp_buf_length(id root) {
    size_t rootLen;
    if ([root isKindOfClass:[NSData class]]) {
        NSData *rootData = root;
        rootLen = rootData.length;
        if (rootLen == 0
            || (rootLen == 1 && ((uint8_t *)rootData.bytes)[0] < 0x7f)) {
            return 1;
        }
    } else if ([root isKindOfClass:[NSString class]]) {
        NSString *rootString = root;
        rootLen = rootString.length;
        if (rootLen == 0
            || (rootLen == 1 && rootString.UTF8String[0] < 0x7f)) {
            return 1;
        }
    } else if ([root isKindOfClass:[NSArray class]]) {
        NSArray *rootArray = root;
        rootLen = 0; 
        for (id object in rootArray) {
            rootLen += rlp_buf_length(object);
        }
    } else {
        NSLog(@"Unsupported type: %@", [root class]);
    }
    if (rootLen <= 55) {
        return 1 + rootLen;
    }
    return rlp_len_length(rootLen) + rootLen;
}

static void _rlp_encode_buf(uint8_t *outBytes, const uint8_t *inBytes, size_t inLength) {
    if (inLength == 0) {
        *outBytes = 0x80;
        return;
    }
    if (inLength == 1 && *inBytes < 0x7f) {
        *outBytes = *inBytes;
        return;
    }
    #define rlp_encode_length(outBytes, inLength, offset) \
    if (inLength <= 55) { \
        *outBytes++ = offset + inLength; \
    } else { \
        size_t lenLength = rlp_len_length(inLength); \
        *outBytes++ = offset + 55 + lenLength; \
        size_t lengthLeft = inLength; \
        size_t lenLengthLeft = lenLength; \
        while (lenLengthLeft --> 0) { \
            outBytes[lenLengthLeft] = (uint8_t)lengthLeft; \
            lengthLeft >>= 8; \
        } \
        outBytes += lenLength; \
    }
    rlp_encode_length(outBytes, inLength, 0x80);
    for (size_t i = 0; i < inLength; i++) {
        outBytes[i] = inBytes[i];
    }
}
static void _rlp_encode_root(uint8_t *outBytes, id root, size_t bufLength) {
    if ([root isKindOfClass:[NSData class]]) {
        NSData *rootData = root;
        _rlp_encode_buf(outBytes, rootData.bytes, rootData.length);
    } else if ([root isKindOfClass:[NSString class]]) {
        NSString *rootString = root;
        _rlp_encode_buf(outBytes, (uint8_t *)rootString.UTF8String, rootString.length);
    } else if ([root isKindOfClass:[NSArray class]]) {
        NSArray *rootArray = root;
        size_t innerLength = bufLength - rlp_len_length(bufLength);
        rlp_encode_length(outBytes, innerLength, 0xc0);
        for (id leaf in rootArray) {
            size_t leafBufLength = rlp_buf_length(leaf);
            _rlp_encode_root(outBytes, leaf, leafBufLength);
            outBytes += leafBufLength;
        }
    } else {
        NSLog(@"Unsupported type: %@", [root class]);
    }
}
static void rlp_encode_root(uint8_t *outBytes, id root) {
    _rlp_encode_root(outBytes, root, rlp_buf_length(root));
}


FOUNDATION_EXPORT NSData *rlp_encode(id root) {
    size_t length = rlp_buf_length(root);
    uint8_t *outBuf = malloc(length);
    _rlp_encode_root(outBuf, root, length);
    return [NSData
        dataWithBytesNoCopy:outBuf
        length:length
        freeWhenDone:YES
    ];
}
FOUNDATION_EXPORT id rlp_decode(NSData *data) {
    return nil;// TODO
}
