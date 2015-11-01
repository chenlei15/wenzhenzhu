# encoding : utf-8
require 'rubygems'
require 'rake'
require 'libsvm'
# require "#{Rails.root}/app/models/naivebayes"
require 'soap/wsdlDriver'
require 'nokogiri'
require "#{Rails.root}/app/models/settings"
# require "crawler_redis"
# require "#{Rails.root}/app/models/complementaryNaiveBayes"

namespace :svm do
  # include CrawlerRedis
  desc "Convert ActSocial Excel training data into libsvm compatitible format"

  task :convert_training_data, :environment do |t, args|

    @@soap_client = SOAP::WSDLDriverFactory.new(Settings.feature_ws_url).create_rpc_driver
    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new
    parameter.kernel_type = Libsvm::KernelType::LINEAR
    doc = Nokogiri::XML(File.open("lib/20150612(positive+negative).xml"))

    word_list = []
    # lines = []
    labels = []
    feature_vectors = []
    doc.css("Worksheet").first.css("Row").each_with_index do |row, i|
      line_str = ""
      pp i
      # if i>1100
      #   break
      # end
      body = row.css("Data")[0].text

      # do features
      document = {:body => body}
      response = @@soap_client.doFeature([document].collect{|p| p.nil? ? "{}" : p.to_json.to_s})

      if response['return'].blank?
        next
      end

      features = response['return'].split("|")[0].split(",")

      data = row.css("Data")[1]
      if data.nil?
          pp '---  skip ----'
          next
      end
      value = data.text
      if value == "1"
          line_str = "+1"
      elsif value == "0"
          line_str = "-1"
      else
          next
      end
      labels << line_str.to_i
      #features= ["wordA=1","wordB=4"]
      # temp_arr = {}
      features.each do |feature|
        feature_name = feature.split("=")[0]
        # feature_occurance = feature.split("=")[1]
        feature_id = word_list.index(feature_name)

        if feature_id.nil?
            word_list << feature_name
        #     feature_id = word_list.size - 1
        # else
        #     feature_id += 1
        end
        # temp_arr[feature_id] = feature_occurance
      end
      feature_vector = word_list.map { |word| 
          features.each_with_index do |feature,i|
            if feature.include? word
              feature_occurance = feature.split("=")[1]
              return feature_occurance
            end
            if i >= features.size
              return 0
            end
         }
        feature_vectors << Libsvm::Node.features(feature_vector）
      # temp_arr.sort.each do |f|
      #   line_str += " "+f[0].to_s+":"+f[1]
      # end
      # lines << line_str

    end;nil#end doc
    problem.set_examples(labels, feature_vectors)
    model = Libsvm::Model.train(problem, parameter)

  end
end
