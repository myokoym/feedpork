module Feedcellar
  class GroongaSercher
    class << self
      def search(database, words, options)
        feeds = database.feeds
        feeds = feeds.select do |feed|
          expression = nil
          words.each do |word|
            sub_expression = (feed.title =~ word) |
                             (feed.description =~ word)
            if expression.nil?
              expression = sub_expression
            else
              expression &= sub_expression
            end
          end

          if options[:mtime]
            base_date = (Time.now - (options[:mtime] * 60 * 60 * 24))
            mtime_expression = feed.date > base_date
            if expression.nil?
              expression = mtime_expression
            else
              expression &= mtime_expression
            end
          end

          if options[:resource]
            resource_expression = feed.resource =~ options[:resource]
            if expression.nil?
              expression = resource_expression
            else
              expression &= resource_expression
            end
          end

          expression
        end

        order = options[:reverse] ? "descending" : "ascending"
        sorted_feeds = feeds.sort([{:key => "date", :order => order}])

        sorted_feeds
      end
    end
  end
end