// =-=-=-=-=-=-=-
#include "apiHeaderAll.hpp"
#include "msParam.hpp"
#include "reGlobalsExtern.hpp"
#include "irods_ms_plugin.hpp"

// =-=-=-=-=-=-=-
// STL/boost Includes
#include <string>
#include <iostream>
#include <vector>
#include <boost/algorithm/string.hpp>

extern "C" {
    // =-=-=-=-=-=-=-
    // Returns the meta data as a string for the image.  Example:  CompressionType=JPEG%Width=10%Height=20
    int msi_str_replace_impl(msParam_t* _in, msParam_t* _search, msParam_t* _replace, msParam_t* _out, ruleExecInfo_t* rei) {
        using std::cout;
        using std::endl;
        using std::string;

        char *inStr = parseMspForStr( _in );
        if( !inStr ) return SYS_INVALID_INPUT_PARAM;

        char *search = parseMspForStr( _search );
        if( !search ) return SYS_INVALID_INPUT_PARAM;

        char *replace = parseMspForStr( _replace );
        if( !replace ) return SYS_INVALID_INPUT_PARAM;

        string srchStr = string(search);
        string replStr = string(replace);
        string outStr = string(inStr);

        size_t pos = 0;
        while ((pos = outStr.find(srchStr, pos)) != std::string::npos) {
             outStr.replace(pos, srchStr.length(), replStr);
             pos += replStr.length();
        }

        fillStrInMsParam(_out, outStr.c_str());

        // Done
        return 0;
    }

    irods::ms_table_entry* plugin_factory() {
        irods::ms_table_entry* msvc = new irods::ms_table_entry(4);
        
        msvc->add_operation("msi_str_replace_impl", "msi_str_replace");
        
        return msvc;
    }

} // extern "C"
