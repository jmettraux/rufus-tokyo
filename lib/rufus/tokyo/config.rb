#--
# Copyright (c) 2009, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


module Rufus
module Tokyo

  #
  # Methods for setting up / tuning a Cabinet.
  #
  module CabinetConfig

    protected

    #
    # Given a path, a hash of parameters and a suffix,
    #
    # a) makes sure that the path has the given suffix or raises an exception
    # b) gathers params found in the path (#) or in params
    # c) determines the config as set by the parameters
    #
    # Suffix is optional, if present, it will be enforced.
    #
    def determine_conf (path, params, required_type=nil)

      if path.index('#')

        ss = path.split('#')
        path = ss.shift

        ss.each { |p| pp = p.split('='); params[pp[0]] = pp[1] }
      end

      params = params.inject({}) { |h, (k, v)| h[k.to_sym] = v; h }

      [
        {
          :params => params,
          :mode => determine_open_mode(params),
          :mutex => (params[:mutex].to_s == 'true'),
          #:indexes => params[:idx] || params[:indexes],
          :xmsiz => (params[:xmsiz] || 67108864).to_i,
        },
        determine_type_and_path(path, params, required_type),
        determine_tuning_values(params),
        determine_cache_values(params)

      ].inject({}) { |h, hh| h.merge(hh) }
    end

    def determine_open_mode (params) #:nodoc#

      mode = params[:mode].to_s
      mode = 'wc' if mode.size < 1

      {
        'r' => (1 << 0), # open as a reader
        'w' => (1 << 1), # open as a writer
        'c' => (1 << 2), # writer creating
        't' => (1 << 3), # writer truncating
        'e' => (1 << 4), # open without locking
        'f' => (1 << 5), # lock without blocking
        's' => (1 << 6), # synchronize every transaction (tctdb.h)

      }.inject(0) { |r, (c, v)|

        r = r | v if mode.index(c); r
      }
    end

    def determine_tuning_values (params) #:nodoc#

      o = params[:opts] || ''
      o = {
        'l' => 1 << 0, # large
        'd' => 1 << 1, # deflate
        'b' => 1 << 2, # bzip2
        't' => 1 << 3, # tcbs
        'x' => 1 << 4
      }.inject(0) { |i, (k, v)| i = i | v if o.index(k); i }

      {
        :bnum => (params[:bnum] || 131071).to_i,
        :apow => (params[:apow] || 4).to_i,
        :fpow => (params[:fpow] || 10).to_i,
        :opts => o,

        :lmemb => (params[:lmemb] || 128).to_i,
          # number of members in each leaf page (:btree)
        :nmemb => (params[:nmemb] || 256).to_i,
          # number of members in each non-leaf page (:btree)

        :width => (params[:width] || 255).to_i,
          # width of the value of each record (:fixed)
        :limsiz => (params[:limsiz] || 26_8435_456).to_i
          # limit size of the database file (:fixed)
      }
    end

    def determine_cache_values (params) #:nodoc#

      {
        :rcnum => params[:rcnum].to_i,
        :lcnum => (params[:lcnum] || 2048).to_i,
        :ncnum => (params[:ncnum] || 512).to_i
      }
    end

    CABINET_SUFFIXES = {
      :hash => '.tch', :btree => '.tcb', :fixed => '.tcf', :table => '.tct'
    }

    CABINET_TYPES = CABINET_SUFFIXES.invert

    def determine_type_and_path (path, params, required_type) #:nodoc#

      type = required_type || params[:type]
      ext = File.extname(path)

      if ext == ''
        suffix = CABINET_SUFFIXES[type]
        path = path + suffix
      else
        suffix = ext
        type ||= CABINET_TYPES[ext]
      end

      raise "path '#{path}' must be suffixed with #{suffix}" \
        if suffix and File.extname(path) != suffix

      { :path => path, :type => type }
    end
  end

end
end

