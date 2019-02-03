//
// Created by Toplica Tanasković <toplica.tanaskovic@tn-tech.co.rs> on 2018-12-21.
// Please see the LICENSE in project root.
//

#include "Converter.h"

#include <string>
#include <vector>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/classification.hpp>
#include <boost/regex.hpp>

using namespace std;

Converter::Converter(istream &source, ostream &destination) : m_source(source), m_destination(destination) {
}

void Converter::convert() {
    std::string line;
    properties_t properties;
    while (std::getline(m_source, line)) {
        auto property = parse_line(line);
        if (property.first.empty()) {
            continue;
        }
        properties.emplace(parse_line(line));
    }

    write_properties(properties);
}

Converter::property_t Converter::parse_line(const std::string &line) {
    vector<string> segments;
    boost::split(segments, line, boost::is_any_of("="));
    if (segments.size() < 2) {
        return property_t();
    }

    const string key = segments[0];
    if (!key_valid(key)) {
        return property_t();
    }

    string value = segments[1];
    for (auto i = 2; i < segments.size(); ++i) {
        value += '=' + segments[i];
    }

    return make_pair(segments[0], value);
}

void Converter::write_properties(const properties_t &properties) {
    m_destination << "{";
    for (const auto &property: properties) {
        write_property(property);
        m_destination << ",";
    }
    if (!properties.empty()) {
        long pos = m_destination.tellp();
        --pos;
        m_destination.seekp(pos);
    }
    m_destination << "}";
}

void Converter::write_property(const property_t &property) {
    m_destination << "\"" << property.first << "\":\"" << property.second << "\"";
}

bool Converter::key_valid(const std::string &key) {
    const static boost::regex expression("^[a-zA-Z]+[a-zA-Z\\d_]*$");
    return boost::regex_match(key, expression);
}


