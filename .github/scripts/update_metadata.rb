#!/usr/bin/env ruby
require 'yaml'
require 'date'
require 'front_matter_parser'

# 포스트 디렉토리 경로
POSTS_DIR = '_posts'

# 포스트 파일 목록 가져오기
post_files = Dir.glob(File.join(POSTS_DIR, '*.md'))

post_files.each do |file_path|
  begin
    # 파일 내용 읽기
    content = File.read(file_path)

    # Front Matter 파싱
    parsed = FrontMatterParser::Parser.parse_file(file_path)
    front_matter = parsed.front_matter

    modified = false

    # 작성일(date) 확인 및 설정
    if !front_matter.key?('date')
      # 파일 이름에서 날짜 추출 (YYYY-MM-DD-title.md 형식 가정)
      filename_date = File.basename(file_path).match(/^(\d{4}-\d{2}-\d{2})/)
      if filename_date
        front_matter['date'] = filename_date[1]
        modified = true
      else
        # 날짜를 파일 생성일로 설정
        front_matter['date'] = Date.today.to_s
        modified = true
      end
    end

    # 수정일(last_modified_at) 업데이트
    front_matter['last_modified_at'] = Date.today.to_s
    modified = true

    # 카테고리가 없는 경우 기본 카테고리 설정
    if !front_matter.key?('categories') || front_matter['categories'].empty?
      # 파일 내용에 따라 적절한 카테고리를 추론할 수도 있지만,
      # 여기서는 기본값으로 GitHub 카테고리를 설정합니다
      front_matter['categories'] = ['1. GitHub']
      modified = true
    end

    if modified
      # 수정된 Front Matter로 파일 업데이트
      new_front_matter = front_matter.to_yaml.sub(/^---\n/, '').sub(/\n---\n$/, '')
      new_content = "---\n#{new_front_matter}---\n#{parsed.content}"
      File.write(file_path, new_content)
      puts "Updated metadata for #{file_path}"
    end
  rescue => e
    puts "Error processing #{file_path}: #{e.message}"
  end
end
