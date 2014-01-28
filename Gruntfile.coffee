module.exports = (grunt) ->

    # Measure how long Grunt tasks take
    require('time-grunt')(grunt)

    # Load grunt tasks automatically
    require('load-grunt-tasks')(grunt)

    pkgObj = grunt.file.readJSON('package.json')
    pkgObj.cleanName = pkgObj.name.replace(/-/gi, ' ')

    grunt.initConfig

        # Project settings
        app:
            src: 'src'
            dist: 'dist'
            tools: 'tools'
            iospath: 'var/mobile/Library/iWidgets'
            fullPath: '<%= app.dist %>/<%= pkg.name %>/<%= app.iospath %>/' + pkgObj.cleanName
            glyphSubset: '0123456789AMP:'

        pkg: pkgObj

        coffeelint:
            options:
                'indentation':
                    'value': 4
                'max_line_length':
                    'level': 'ignore'
            main: '<%= app.src %>/script/script.coffee'
            gruntfile: 'Gruntfile.coffee'

        coffee:
            options:
                sourceMap: true
                bare: true
            compile:
                files:
                    '<%= app.src %>/script/script.js': '<%= app.src %>/script/script.coffee'

        notify:
            coffee:
                options:
                    title: "#{pkgObj.cleanName} v<%= pkg.version %>"
                    message: 'CoffeeScript compiled.'
            build:
                options:
                    title: "#{pkgObj.cleanName} v<%= pkg.version %>"
                    message: "The build task completed successfully."

        # Connect server
        connect:
            server:
                options:
                    base: '<%= app.src %>'
                    livereload: 35729
                    hostname: '*'
                    open: true
                    debug: true
                    keepalive: true

        concurrent:
            server: ['connect:server', 'watch']

        # Watch tasks
        watch:
            files:
                options:
                    livereload: '<%= connect.server.options.livereload %>'
                files: [
                    '<%= app.src %>/Widget.html'
                    '<%= app.src %>/script/script.js'
                    '<%= app.src %>/css/style.css'
                ]
            coffee:
                files: '<%= app.src %>/script/script.coffee'
                tasks: [
                    'coffeelint:main'
                    'coffee'
                    'notify:coffee'
                ]
            gruntfile:
                files: 'Gruntfile.coffee'
                tasks: 'coffeelint:gruntfile'

        # Build specific
        clean: ['<%= app.dist %>']
        copy:
            css:
                options:
                    process: (content, srcpath) ->
                        content.replace('#timeface{color:red!important;}/*removed on build*/\n', '')
                files: [
                    expand: true
                    cwd: '<%= app.src %>/css/'
                    src: [
                        'style.css'
                    ]
                    dest: '<%= app.fullPath %>/css/'
                ]
            dist:
                files: [
                    expand: true
                    cwd: '<%= app.src %>'
                    src: [
                        'Options.plist'
                        'Widget.plist'
                        'fonts/*'
                    ]
                    dest: '<%= app.fullPath %>/'
                ]
            controlFile:
                options:
                    process: (content, srcpath) ->
                        """
                            #{content}Name: #{pkgObj.cleanName}
                            Version: #{pkgObj.version}
                            Description: #{pkgObj.description}
                            Homepage: #{pkgObj.homepage}
                            Author: #{pkgObj.author}
                            Maintainer: #{pkgObj.author}

                        """
                files: [
                    expand: true
                    cwd: '<%= app.src %>'
                    src: [
                        'control.txt'
                    ]
                    dest: '<%= app.dist %>/<%= pkg.name %>/DEBIAN/'
                    rename: (dest, src) ->
                        dest + src.replace(src.substr(-4), '')
                ]
        removelogging:
            dist:
                src: '<%= app.src %>/script/script.js'
                dest: '<%= app.fullPath %>/script/script.js'

        uglify:
            options:
                banner: "/*! #{pkgObj.cleanName} <%= pkg.version %> by <%= pkg.author %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
            dist:
                src: '<%= app.fullPath %>/script/script.js'
                dest: '<%= app.fullPath %>/script/script.js'

        htmlmin:
            dist:
                options:
                    removeComments: true
                    collapseWhitespace: true
                files:  '<%= app.fullPath %>/Widget.html': '<%= app.src %>/Widget.html'

        cssmin:
            dist:
                options:
                    banner: "/*! #{pkgObj.cleanName} <%= pkg.version %> by <%= pkg.author %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
                files: '<%= app.fullPath %>/css/style.css': ['<%= app.fullPath %>/css/style.css']

        shell:
            optimizeFonts: # this is not working properly yet
                options:
                    stderr: true
                    stdin: true
                    stdout: true
                    execOptions:
                        cwd: '<%= app.tools %>/font-optimizer'
                command: 'find "../../<%= app.fullPath %>/fonts" -maxdepth 1 -type f -exec ./subset.pl --chars="<%= app.glyphSubset %>" {} {} \\;'
            createDeb:
                options:
                    stderr: true
                    stdin: true
                    stdout: true
                    execOptions:
                        cwd: '<%= app.dist %>'
                command: 'dpkg-deb -Zgzip -b <%= pkg.name %>'

    grunt.registerTask 'default', [
        'coffeelint'
        'coffee'
    ]

    grunt.registerTask 'serve', [
        'concurrent:server'
    ]

    grunt.registerTask 'build', [
        'coffeelint'
        'coffee'
        'clean'
        'copy'
        'removelogging'
        'uglify'
        'htmlmin'
        'cssmin'
        'shell:createDeb'
        'notify:build'
    ]
