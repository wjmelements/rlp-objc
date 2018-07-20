#import "rlp.h"

#import <assert.h>

void test_ethWikiEncodeExamples() {
    NSData *dog = rlp_encode(@"dog");
    assert(dog.length == 4);
    uint8_t *bytes = (uint8_t *)dog.bytes;
    assert(bytes[0] == 0x83);
    assert(bytes[1] == 'd');
    assert(bytes[2] == 'o');
    assert(bytes[3] == 'g');

    NSData *empty;
    #define checkEmpty(input, expected) \
        empty = rlp_encode(input); \
        assert(empty.length == 1); \
        bytes = (uint8_t *)empty.bytes; \
        assert(bytes[0] == expected);
    checkEmpty(@"", 0x80);
    checkEmpty(@[], 0xc0);
    #undef checkEmpty

}

int main() {
    test_ethWikiEncodeExamples();
    return 0;
}
