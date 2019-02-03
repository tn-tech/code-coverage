//
// Created by Toplica Tanasković <toplica.tanaskovic@tn-tech.co.rs> on 2018-12-21.
// Please see the LICENSE in project root.
//

#include <gtest/gtest.h>

#include <Converter.h>

#include <sstream>

using namespace std;

TEST(ConverterTest, shouldReturnEmptyJSONIfPropertiesAreEmpty) {
    ostringstream oss;
    istringstream iss;

    Converter c(iss, oss);
    c.convert();
    EXPECT_EQ(oss.str(), "{}");
}

TEST(ConverterTest, shouldIgnoreInvalidLines) {
    ostringstream oss;
    istringstream iss("Foo Bar Baz\n"
                      "one two three\n"
                      "4prop=thing\n"
                      "kaboom-no\n"
                      "_invalid=123\n"
                      "first_valid=42\n"
                      "secondvalid=21");

    Converter c(iss, oss);
    c.convert();
    EXPECT_EQ(oss.str(), "{\"first_valid\":\"42\",\"secondvalid\":\"21\"}");
}

TEST(ConverterTest, shouldAcceptPropertyWithNoValue) {
    ostringstream oss;
    istringstream iss("empty=");
    Converter c(iss, oss);
    c.convert();
    EXPECT_EQ(oss.str(), "{\"empty\":\"\"}");
}

TEST(ConverterTest, shouldAcceptPropertiesThatHasEqualsInValue) {
    ostringstream oss;
    istringstream iss("withequals=2+2=4");
    Converter c(iss, oss);
    c.convert();
    EXPECT_EQ(oss.str(), "{\"withequals\":\"2+2=4\"}");
}

TEST(ConverterTest, shouldAcceptUnmatchedSingleQuotesInPropertyValue) {
    ostringstream oss;
    istringstream iss("with_single_quote=4'2");
    Converter c(iss, oss);
    c.convert();
    EXPECT_EQ(oss.str(), "{\"with_single_quote\":\"4'2\"}");
}

TEST(ConverterTest, shouldAcceptMatchedSingleQuotesInPropertyValue) {
    ostringstream oss;
    istringstream iss("with_single_quote=4'2'");
    Converter c(iss, oss);
    c.convert();
    EXPECT_EQ(oss.str(), "{\"with_single_quote\":\"4'2'\"}");
}

TEST(ConverterTest, shouldAcceptUnmatchedDoubleQuotesInPropertyValue) {
    ostringstream oss;
    istringstream iss("with_single_quote=4\"2");
    Converter c(iss, oss);
    c.convert();
    EXPECT_EQ(oss.str(), "{\"with_single_quote\":\"4\"2\"}");
}

TEST(ConverterTest, shouldAcceptMatchedDoubleQuotesInPropertyValue) {
    ostringstream oss;
    istringstream iss("with_single_quote=4\"2\"");
    Converter c(iss, oss);
    c.convert();
    EXPECT_EQ(oss.str(), "{\"with_single_quote\":\"4\"2\"\"}");
}