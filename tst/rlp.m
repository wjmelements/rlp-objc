#import "rlp.h"

#import <assert.h>

void test_setTheory3() {
    NSArray *root = @[ @[], @[@[]], @[ @[], @[@[]] ] ];
    NSData *rlp = rlp_encode(root);
    assert(rlp.length == 8);
    uint8_t *bytes = (uint8_t *)rlp.bytes;
    uint8_t expected[8] = {0xc7, 0xc0, 0xc1, 0xc0, 0xc3, 0xc0, 0xc1, 0xc0};
    for (int i = 0; i < 8; i++) {
        assert(expected[i] == bytes[i]);
    }
}

void test_loremIpsum() {
    NSString *in = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit";
    NSData *out = rlp_encode(in);
    uint8_t *bytes = (uint8_t *)out.bytes;
    uint8_t *inBytes = (uint8_t *)in.UTF8String;
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
    uint8_t *bytes = (uint8_t *)out.bytes;
    assert(bytes[0] == 0x83);
    assert(bytes[1] == 'd');
    assert(bytes[2] == 'o');
    assert(bytes[3] == 'g');

    #define checkByte(input, expected) \
        out = rlp_encode(input); \
        assert(out.length == 1); \
        bytes = (uint8_t *)out.bytes; \
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
    bytes = (uint8_t *)out.bytes;
    assert(bytes[0] == 0x82);
    assert(bytes[1] == 0x04);
    assert(bytes[2] == 0x00);

    test_setTheory3();

    test_loremIpsum();
}

int main() {
    test_ethWikiEncodeExamples();
    return 0;
}
