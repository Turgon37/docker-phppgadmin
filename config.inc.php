<?php
    /**
     * Central phpPgAdmin configuration.
     */

    // init hosts to db fallback
    $hosts = array('db');

    /* Set by environment */
    if (!empty(getenv('POSTGRES_HOSTS'))) {
        $hosts = explode(',', getenv('POSTGRES_HOSTS'));
        $names = explode(',', getenv('POSTGRES_NAMES'));
        $ports = explode(',', getenv('POSTGRES_PORTS'));
    } elseif (!empty(getenv('POSTGRES_HOST'))) {
        $hosts = array(getenv('POSTGRES_HOST'));
        $names = array(getenv('POSTGRES_NAME'));
        $ports = array(getenv('POSTGRES_PORT'));
    }

    /* Server settings */
    for ($i = 0; isset($hosts[$i]); $i++) {
        // Hostname or IP address for server.  Use '' for UNIX domain socket.
        // use 'localhost' for TCP/IP connection on this computer
        $conf['servers'][$i]['host'] = $hosts[$i];

        if ( isset($names[$i]) ) {
            // Display name for the server on the login screen
            $conf['servers'][$i]['desc'] = $names[$i];
        }
        if ( isset($ports[$i]) && !empty($ports[$i]) ) {
            // Database port on server (5432 is the PostgreSQL default)
            $conf['servers'][$i]['port'] = $ports[$i];
        } else {
            $conf['servers'][$i]['port'] = 5432;
        }

        // default settings for all servers

        // Database SSL mode
        // Possible options: disable, allow, prefer, require
        // To require SSL on older servers use option: legacy
        // To ignore the SSL mode, use option: unspecified
        $conf['servers'][$i]['sslmode'] = 'allow';

        // Change the default database only if you cannot connect to template1.
        // For a PostgreSQL 8.1+ server, you can set this to 'postgres'.
        $conf['servers'][$i]['defaultdb'] = getenv('POSTGRES_DEFAULTDB');

        // Specify the path to the database dump utilities for this server.
        // You can set these to '' if no dumper is available.
        $conf['servers'][$i]['pg_dump_path'] = '/usr/bin/pg_dump';
        $conf['servers'][$i]['pg_dumpall_path'] = '/usr/bin/pg_dumpall';
    }

    /* Groups definition */
    /* Groups allow administrators to logicaly group servers together under
     * group nodes in the left browser tree
     *
     * The group '0' description
     */
    //$conf['srv_groups'][0]['desc'] = 'group one';

    /* Add here servers indexes belonging to the group '0' seperated by comma */
    //$conf['srv_groups'][0]['servers'] = '0,1,2';

    /* A server can belong to multi groups. Here server 1 is referenced in both
     * 'group one' and 'group two'*/
    //$conf['srv_groups'][1]['desc'] = 'group two';
    //$conf['srv_groups'][1]['servers'] = '3,1';

    /* A group can be nested in one or more existing groups using the 'parents'
     * parameter. Here the group 'group three' contains only one server and will
     * appear as a subgroup in both 'group one' and 'group two':
     */
    //$conf['srv_groups'][2]['desc'] = 'group three';
    //$conf['srv_groups'][2]['servers'] = '4';
    //$conf['srv_groups'][2]['parents'] = '0,1';

    /* Warning: Only groups with no parents appears at the root of the tree. */


    // Default language. E.g.: 'english', 'polish', etc.  See lang/ directory
    // for all possibilities. If you specify 'auto' (the default) it will use
    // your browser preference.
    $conf['default_lang'] = 'auto';

    // AutoComplete uses AJAX interaction to list foreign key values
    // on insert fields. It currently only works on single column
    // foreign keys. You can choose one of the following values:
    // 'default on' enables AutoComplete and turns it on by default.
    // 'default off' enables AutoComplete but turns it off by default.
    // 'disable' disables AutoComplete.
    $conf['autocomplete'] = 'default on';

    // If extra login security is true, then logins via phpPgAdmin with no
    // password or certain usernames (pgsql, postgres, root, administrator)
    // will be denied. Only set this false once you have read the FAQ and
    // understand how to change PostgreSQL's pg_hba.conf to enable
    // passworded local connections.
    $conf['extra_login_security'] = boolval(getenv('PHPPGADMIN_LOGIN_SECURITY'));

    // Only show owned databases?
    // Note: This will simply hide other databases in the list - this does
    // not in any way prevent your users from seeing other database by
    // other means. (e.g. Run 'SELECT * FROM pg_database' in the SQL area.)
    $conf['owned_only'] = boolval(getenv('PHPPGADMIN_OWNED_ONLY'));

    // Display comments on objects?  Comments are a good way of documenting
    // a database, but they do take up space in the interface.
    $conf['show_comments'] = boolval(getenv('PHPPGADMIN_SHOW_COMMENTS'));

    // Display "advanced" objects? Setting this to true will show
    // aggregates, types, operators, operator classes, conversions,
    // languages and casts in phpPgAdmin. These objects are rarely
    // administered and can clutter the interface.
    $conf['show_advanced'] = boolval(getenv('PHPPGADMIN_SHOW_ADVANCED'));

    // Display "system" objects?
    $conf['show_system'] = boolval(getenv('PHPPGADMIN_SHOW_SYSTEM'));

    // Minimum length users can set their password to.
    $conf['min_password_length'] = 8;

    // Width of the left frame in pixels (object browser)
    $conf['left_width'] = 200;

    // Which look & feel theme to use
    include __DIR__ . "/../themes/themes.php";
    $theme = getenv('PHPPGADMIN_THEME');
    if ( !isset($appThemes[$theme]) ) {
        $theme = 'default';
    }
    $conf['theme'] = $theme;

    // Show OIDs when browsing tables?
    $conf['show_oids'] = boolval(getenv('PHPPGADMIN_SHOW_OIDS'));

    // Max rows to show on a page when browsing record sets
    $conf['max_rows'] = 30;

    // Max chars of each field to display by default in browse mode
    $conf['max_chars'] = 50;

    // Send XHTML strict headers?
    $conf['use_xhtml_strict'] = boolval(getenv('PHPPGADMIN_USE_XHTML_STRICT'));

    // Base URL for PostgreSQL documentation.
    // '%s', if present, will be replaced with the PostgreSQL version
    // (e.g. 8.4 )
    $conf['help_base'] = 'http://www.postgresql.org/docs/%s/interactive/';

    // Configuration for ajax scripts
    // Time in seconds. If set to 0, refreshing data using ajax will be disabled (locks and activity pages)
    $conf['ajax_refresh'] = 3;

    /** Plugins management
     * Add plugin names to the following array to activate them
     * Example:
     *   $conf['plugins'] = array(
     *     'Example',
     *     'Slony'
     *   );
     */
    $plugins_names = getenv('PHPPGADMIN_PLUGINS');
    if ( strlen($plugins_names) === 0 ) {
        $conf['plugins'] = array();
    } else {
        $conf['plugins'] = explode(',', $plugins_names);
    }

    /*****************************************
     * Don't modify anything below this line *
     *****************************************/

    $conf['version'] = 19;

?>
