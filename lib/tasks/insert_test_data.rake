namespace :db do
  desc 'Inserta canales y videos con transcripciones cargadas desde cualquier archivo .txt en lib/tasks/transcriptions/'
  task insert_test_channels_and_videos: :environment do
    user = User.first
    max = 32
    if user
      channel = Channel.create!(
        name: '25_sources(test)',
        state: :unchecked,
        user: user,
        external_source: 'ICRT',
        external_source_id: '123456789'
      )

      transcription_files = Dir[Rails.root.join('lib', 'tasks', 'transcriptions', '*.txt')]

      if transcription_files.size < max
        puts 'Error: Se requieren al menos 32 archivos .txt para completar las transcripciones.'
        return
      end

      transcription_files.first(max).each_with_index do |file, index|
        video = Video.create!(
          channel: channel,
          state: 2,
          processed_at: Time.at(rand(Time.new(2024, 10, 1).to_f..Time.new(2024, 10, 25).to_f)),
          external_created_at: Time.at(rand(Time.new(2023, 1, 1).to_f..Time.new(2023, 12, 31).to_f)),
          text: File.basename(file)
        )

        video.process_video_log.update_attribute(:transcribed, true)

        content = File.read(file)
        Transcription.create!(
          video: video,
          content: content
        )

        puts "Video #{index + 1} y transcripción desde #{File.basename(file)} insertados."
      end

      puts 'Canal y 32 videos con transcripciones insertados exitosamente.'
    else
      puts 'No se encontró un usuario para asociar el canal y los videos.'
    end
  end

  desc 'Completa el campo file_name en los videos existentes con el nombre del archivo de transcripción correspondiente'
  task update_file_name_for_videos: :environment do
    transcription_files = Dir[Rails.root.join('lib', 'tasks', 'transcriptions', '*.txt')]

    Video.find_each do |video|
      matching_file = transcription_files.find do |file|
        File.read(file).strip == video.transcription&.content&.strip
      end

      if matching_file
        video.update(text: File.basename(matching_file))
        puts "Actualizado file_name para Video ID #{video.id} con #{File.basename(matching_file)}."
      else
        puts "No se encontró un archivo de transcripción coincidente para Video ID #{video.id}."
      end
    end

    puts 'Actualización del campo file_name completada.'
  end
end
