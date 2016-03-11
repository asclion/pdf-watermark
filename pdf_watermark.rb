#!/usr/bin/env ruby

# prawn can easily create pdf files. Must be 0.12.0, not above to support :template
require 'prawn'

def write_watermark_pdf(input_file, output_file, watermark_text)
	# Start the new document by using a template
	pdf = Prawn::Document.new(:skip_page_creation => true, :optimize_objects => true, :template => input_file)
	
	# Draw a watermark on all pages
	# by using #repeat() function, its block will be stamped and so applied really quickly!
	# stamp is an object in cache that can be reused without duplicating the resources.
	pdf.repeat :all do
		pdf.transparent(0.2, 0.2) do
			pdf.fill_color "555555"
			pdf.text_box watermark_text,
				:size   => 50,
				:width  => pdf.bounds.width,
				:height => pdf.bounds.height,
				:align  => :center,
				:valign => :center,
				:at     => [0, pdf.bounds.height],
				:rotate => Math.atan2(pdf.bounds.height, pdf.bounds.width)*180/Math::PI,
				:rotate_around => :center
		end
	end

	# Encrypt the document. This is a cheap non safe protection as some PDF renderers may not respect it.
	# Should be protected against print, copy/paste, edition, etc
	# Can be opened by anyone without password
	pdf.encrypt_document	:permissions => {
								:print_document 	=> false,
								:modify_contents 	=> false,
								:copy_contents 		=> false,
								:modify_annotations	=> false
							},
							:owner_password => :random
							
	pdf.render_file(output_file)
end

if ARGV.size != 3
  puts "Usage: <input-file> <output-file> <watermark-text>"
  exit
end

pdf_in = ARGV[0]
pdf_out = ARGV[1]
text = ARGV[2].sub('\n', "\n")

t = Time.new
puts "Add watermark text: #{text}"
write_watermark_pdf(pdf_in, pdf_out,text)
puts "Watermark rendered in #{Time.new-t}s"
puts "Result is at #{pdf_out}"
