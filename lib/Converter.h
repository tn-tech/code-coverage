//
// Created by Toplica Tanasković <toplica.tanaskovic@tn-tech.co.rs> on 2018-12-21.
// Please see the LICENSE in project root.
//

#ifndef CONVERTER_H
#define CONVERTER_H

#include <iostream>
#include <map>
#include <string>
#include <utility>
#include <list>

class Converter final {
public:
    Converter() = delete;

    Converter(const Converter &) = delete;

    Converter(Converter &&) = delete;

    Converter &operator=(const Converter &) = delete;

    Converter &operator=(const Converter &&) = delete;

    Converter(std::istream &source, std::ostream &destination);

    void convert();

private:
    using property_t = std::pair<std::string, std::string>;
    using properties_t = std::map<std::string, std::string>;

    std::istream &m_source;
    std::ostream &m_destination;

    property_t parse_line(const std::string &line);

    void write_properties(const properties_t &properties);

    void write_property(const property_t &aProperty);

    static bool key_valid(const std::string &key);
};


#endif //COVERTER_H
