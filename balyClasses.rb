#We start with our Error classes, which will allow us to identify
# specific issues and direct how to best resolve them
class ClassificationError < StandardError
end

class PrefixError < ClassificationError
end

class SuffixError < ClassificationError
end

class Slide
    def initialize(categorization)
        

    end
end