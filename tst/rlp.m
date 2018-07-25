#import "rlp.h"

// FIXME this include is required to link under wmake but not to build :(
#import "NSData+RLP.h"

#import <assert.h>

void test_catDog() {
    NSArray *root = @[ @"cat", @"dog" ];
    NSData *rlp = rlp_encode(root);
    assert(rlp.length == 9);
    const uint8_t *bytes = rlp.bytes;
    assert(bytes[0] == 0xc8);
    assert(bytes[1] == 0x83);
    assert(bytes[2] == 'c');
    assert(bytes[3] == 'a');
    assert(bytes[4] == 't');
    assert(bytes[5] == 0x83);
    assert(bytes[6] == 'd');
    assert(bytes[7] == 'o');
    assert(bytes[8] == 'g');
}

void test_setTheory3() {
    NSArray *root = @[ @[], @[@[]], @[ @[], @[@[]] ] ];
    NSData *rlp = rlp_encode(root);
    assert(rlp.length == 8);
    const uint8_t *bytes = rlp.bytes;
    uint8_t expected[8] = {0xc7, 0xc0, 0xc1, 0xc0, 0xc3, 0xc0, 0xc1, 0xc0};
    for (int i = 0; i < 8; i++) {
        assert(expected[i] == bytes[i]);
    }
}

void test_loremIpsum() {
    NSString *in = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit";
    NSData *out = rlp_encode(in);
    const uint8_t *bytes = out.bytes;
    const uint8_t *inBytes = (const uint8_t *)in.UTF8String;
    assert(bytes[0] == 0xb8);
    assert(bytes[1] == 0x38);
    bytes += 2;
    for (size_t i = 0; inBytes[i]; i++) {
        assert(bytes[i] == inBytes[i]);
    }
}

void test_ethWikiEncodeExamples() {
    NSData *out = rlp_encode(@"dog");
    assert(out.length == 4);
    const uint8_t *bytes = out.bytes;
    assert(bytes[0] == 0x83);
    assert(bytes[1] == 'd');
    assert(bytes[2] == 'o');
    assert(bytes[3] == 'g');

    #define checkByte(input, expected) \
        out = rlp_encode(input); \
        assert(out.length == 1); \
        bytes = out.bytes; \
        assert(bytes[0] == expected);
    checkByte(@"", 0x80);
    checkByte(@[], 0xc0);

    uint8_t value = 0;
    NSData *input;
    input = [NSData dataWithBytes:&value length:1];
    checkByte(input, 0);
    value = 15;
    input = [NSData dataWithBytes:&value length:1];
    checkByte(input, 0x0f);
    #undef checkByte

    char value16[2] = { 0x04, 0x00 };
    input = [NSData dataWithBytes:value16 length:2];
    out = rlp_encode(input);
    assert(out.length == 3);
    bytes = out.bytes;
    assert(bytes[0] == 0x82);
    assert(bytes[1] == 0x04);
    assert(bytes[2] == 0x00);

    test_catDog();

    test_setTheory3();

    test_loremIpsum();
}

static NSData *fromString(NSString *str) {
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}
static NSData *fromHex(NSString *hex) {
    NSMutableData *outputData = [NSMutableData
        dataWithCapacity:32
    ];
    char workingString[3] = { 0, 0, 0 };

    uint32_t start = 0;
    if (hex.UTF8String[1] == 'x') {
        start = 2;
    }
    if (hex.length % 2) {
        workingString[0] = '0';
        workingString[1] = hex.UTF8String[start];
        unsigned long byte = strtoul(workingString, NULL, 16); // TODO replace strtoul
        [outputData appendBytes:&byte length:1];
        start++;
    }
    for (uint32_t i = start; i < hex.length; i+=2) {
        workingString[0] = hex.UTF8String[i];
        workingString[1] = hex.UTF8String[i+1];
        unsigned long byte = strtoul(workingString, NULL, 16); // TODO replace strtoul
        [outputData appendBytes:&byte length:1];
    }
    return outputData;
}
static NSData *fromBase64(NSString *base64) {
    return [[NSData alloc]
        initWithBase64EncodedString:base64
        options:0
    ];
}

void test_encodeDecode() {
    id subject = @[ fromString(@"cat"), fromString(@"dog") ];
    NSArray *out = rlp_decode(rlp_encode(subject));
    assert([subject isEqual:out]);
    subject = fromString(@"Lorem ipsum dolor sit amet, consectetur adipisicing elit");
    #define checkEncodeDecode() \
    out = rlp_decode(rlp_encode(subject)); \
    assert([subject isEqual:out]);
    checkEncodeDecode();
    subject = @[ subject ];
    checkEncodeDecode();
    subject = @[ @[], @[@[]], @[ @[], @[@[]] ] ];
    checkEncodeDecode();
    subject = @[ @[ @[ @[ @[ @[ fromString(@"쩔어") ] ] ] ] ] ];
    checkEncodeDecode();
    subject = @[  fromString(@"1") ];
    checkEncodeDecode();

}

void test_sig() {
    NSArray *in = @[
        fromHex(@"9"),
        fromHex(@"0x4a817c800"),
        fromHex(@"0x5208"),
        fromHex(@"0x3535353535353535353535353535353535353535"),
        fromHex(@"0xDE0B6B3A7640000"),
        fromHex(@"0x"),
        fromHex(@"0x25"),
        fromBase64(@"KO9hNAvZObwhlf5TdWeGYAPhoV08cf9j4VkGIKpjYnY="),
        fromBase64(@"Z8vp2Jl/dhrstwMwSzgAzPVVyfPcZCFLKX+xlmo7bYM=")
    ];
    assert([in isEqual:rlp_decode(rlp_encode(in))]);
    NSData *sig = fromHex(@"0xf86c098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a76400008025a028ef61340bd939bc2195fe537567866003e1a15d3c71ff63e1590620aa636276a067cbe9d8997f761aecb703304b3800ccf555c9f3dc64214b297fb1966a3b6d83");
    assert([in isEqual:rlp_decode(sig)]);

    assert([sig isEqual:rlp_encode(in)]);
    NSArray *out = rlp_decode(sig);
    assert([sig isEqual:rlp_encode(out)]);
}

void test_nsvalue() {
    uint64_t val;
    NSValue *in;
    NSData *out;
    val = 0;
    in = @(val);
    out = rlp_encode(in);
    assert(out.length == 1);
    assert(((uint8_t *)out.bytes)[0] == 0x80);

    val = 1;
    in = @(val);
    out = rlp_encode(in);
    assert(out.length == 1);
    assert(((uint8_t *)out.bytes)[0] == 0x01);
}

int main() {
    test_ethWikiEncodeExamples();
    test_encodeDecode();
    test_sig();
    test_nsvalue();
    return 0;
}
