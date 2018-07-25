#import "NSData+RLP.h"

#import <assert.h>

static void testSingleByte() {
    uint8_t byte = 0xa7;
    NSValue *in = @(byte);
    NSData *out = [NSData rlpFromNSValue:in];
    assert(sizeof(byte) == out.length);
    assert(byte == *(uint8_t *)out.bytes);
}

static void testTwoBytes() {
    uint16_t shrt = 0x1122;
    NSValue *in = @(shrt);
    NSData *out = [NSData rlpFromNSValue:in];
    assert(sizeof(shrt) == out.length);
    // should be big endian
    assert(0x11 == ((uint8_t *)out.bytes)[0]);
    assert(0x22 == ((uint8_t *)out.bytes)[1]);
}

static void testFourBytes() {
    uint32_t lng = 0x11223344;
    NSValue *in = @(lng);
    NSData *out = [NSData rlpFromNSValue:in];
    assert(sizeof(lng) == out.length);
    // should be big endian
    assert(0x11 == ((uint8_t *)out.bytes)[0]);
    assert(0x22 == ((uint8_t *)out.bytes)[1]);
    assert(0x33 == ((uint8_t *)out.bytes)[2]);
    assert(0x44 == ((uint8_t *)out.bytes)[3]);

}

static void testEightBytes() {
    uint64_t lnglng = 0x1122334455667788;
    NSValue *in = @(lnglng);
    NSData *out = [NSData rlpFromNSValue:in];
    assert(sizeof(lnglng) == out.length);
    // should be big endian
    assert(0x11 == ((uint8_t *)out.bytes)[0]);
    assert(0x22 == ((uint8_t *)out.bytes)[1]);
    assert(0x33 == ((uint8_t *)out.bytes)[2]);
    assert(0x44 == ((uint8_t *)out.bytes)[3]);
    assert(0x55 == ((uint8_t *)out.bytes)[4]);
    assert(0x66 == ((uint8_t *)out.bytes)[5]);
    assert(0x77 == ((uint8_t *)out.bytes)[6]);
    assert(0x88 == ((uint8_t *)out.bytes)[7]);

    lnglng = 0x1122;
    in = @(lnglng);
    out = [NSData rlpFromNSValue:in];
    assert(out.length == 2);
    assert(0x11 == ((uint8_t *)out.bytes)[0]);
    assert(0x22 == ((uint8_t *)out.bytes)[1]);

    lnglng = 0x1122;
    in = @(lnglng);
    out = [NSData rlpFromNSValue:in];
    assert(out.length == 2);
    assert(0x11 == ((uint8_t *)out.bytes)[0]);
    assert(0x22 == ((uint8_t *)out.bytes)[1]);
}

static void testZero() {
    uint64_t zero = 0x0;
    NSValue *in = @(zero);
    NSData *out = [NSData rlpFromNSValue:in];
    assert(0 == out.length);
}

int main() {
    testZero();
    testSingleByte();
    testTwoBytes();
    testFourBytes();
    testEightBytes();
    return 0;
}
