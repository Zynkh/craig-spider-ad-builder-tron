class Ad

  attr_accessor :title, :price, :engine, :trans, :km, :stock, :colour, :features_convenience, :features_entertainment, :features_safety, :details, :details_sorted, :images, :colour_field_included

  def initialize(source)
    @title  = source.css('#vehicle-header div div.title h1 span').text
    @price  = source.css('dd.internet span').text

    @features_entertainment = source.css('#features dl:nth-child(3)')
    @features_convenience   = source.css('#features dl:nth-child(2)')
    @features_safety        = source.css('#features dl:nth-child(6)')

    @details = source.css('#overview div')
    @details_sorted = []

    @colour_field_included = nil

    @images = source.css('#dealerPhotos img')
    @fixed_images = []

    sort_details
    assign_details
    build_template
    create_file
    grab_images
  end

  def sort_details
    @sorter_file = "temp.txt"
    detail_sort = File.open(@sorter_file, "w")
    detail_sort.puts @details
    detail_sort.close 

    File.open(@sorter_file, "r") do |file|
      file.readlines.each do |line|

        @colour_field_included = true if line.match("<dt><span>Ext. Colour</span></dt>")

        if line.match('<dd><span>.+<\/span><\/dd>')
          line.gsub!(/<dd><span>(.+)<\/span><\/dd>/, '\1')
          @details_sorted << line
        elsif line.match('<dd class="mileageValue"><span>.+<\/span><\/dd>')
          line.gsub!(/<dd class="mileageValue"><span>(.+)<\/span><\/dd>/, '\1')
          @details_sorted << line
        end
      end
    end
    File.delete(@sorter_file)
  end

  def assign_details
    if @colour_field_included
      @engine = @details_sorted[1]
      @trans  = @details_sorted[2]
      @colour = @details_sorted[3]
      @km     = @details_sorted[4]
      @stock  = @details_sorted[5]
      puts "Colour field: Yes"
    else
      @engine = @details_sorted[1]
      @trans  = @details_sorted[2]
      @colour = "Glorious"
      @km     = @details_sorted[3]
      @stock  = @details_sorted[4]
      puts "Colour field: No"
    end

  end

  def build_template
    @output = " <h2>WESTWOOD HONDA - SERVING THE COMMUNITY SINCE 1978</h2>

              <h3>2400 Barnett Hwy Port Moody BC | V3H 1W3 | 1 (888) 845-2569</h3>

              <h1> #{@title} - Reg #{@price}</h1>

              <h3> | Engine: #{@engine} | Stock #: #{@stock} | Transmission: #{@trans} | Kilometres: #{km} | Colour: #{@colour} | </h3>

              <p>----------</p>
              <p>Westwood Honda's used car buyer's package for all of our vehicles is a thorough safety inspection, complete professional detail and a detailed Car Proof report showing the history of the car you're buying. Comes with a mechanical warranty, tire and rim protection, a full tank of gas and market priced to guarantee you tremendous value with your new purchase. Also comes with 3 free months of Sirius radio where equipped.</p>
              <p>Westwood Honda's Honda Certified program ensures that well-maintained Honda models that are less than five years old or have a maximum of 120,000 miles are covered for major engine and transmission components except for standard maintenance items, body glass and interiors. Honda will repair or replace any covered part that is defective in material or workmanship under normal use, with a $0 deductible.</p>

              #{@features_entertainment}

              #{@features_convenience}

              #{@features_safety}

              <h2>Call us at 1 (888) 845-2569</strong></h2> "
  end

  def create_file
    title_fix = title.gsub("/", " ").gsub(" ", "_").gsub("(","").gsub(")","")
    @full_title = (title_fix + "_" + @stock).chomp
    
    Dir.mkdir(@full_title)
    
    output_filename = @full_title + "/" + @full_title + ".html"
    
    template = File.open(output_filename, "w")
    template.puts @output
    template.close 
    
    puts "Created a template for #{@full_title}"
  end

  def grab_images
    img_url_file = "imgfile.txt"
    prepare_file = File.open(img_url_file, "w")
    prepare_file.puts @images
    prepare_file.close

    File.open(img_url_file, "r") do |file|
      file.readlines.each do |line|
        line.gsub!(/<img src="(.+)" alt="" title="">/, '\1')
        if line.include?('thumb_')
          line.gsub!('thumb_','')
        end
        @fixed_images << line
      end
    end

    fix_file = File.open(img_url_file, "w")
    fix_file.puts @fixed_images
    fix_file.close

    @get_image_command = "wget -q -P ./" + @full_title + " -i imgfile.txt"
    system(@get_image_command)
    puts "Images downloaded" 

    File.delete(img_url_file)
  end

end