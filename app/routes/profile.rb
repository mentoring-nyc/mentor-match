module MentorMatch
  module Profile
    def self.included(base)
      base.before '/signup/complete-profile' do
        authenticate!
      end

      base.before '/signup/success' do
        authenticate!
      end

      base.before '/profile' do
        authenticate!
      end

      base.get '/signup/benefits' do
        show :'signup/benefits'
      end

      base.get '/signup/complete-profile' do
        @profile = current_user.profile || current_user.profile_from_identity
        show :'signup/complete_profile'
      end

      base.post '/signup/complete-profile' do
        @profile = current_user.profile || current_user.profile_from_identity
        @profile.attributes = update_params.merge(role: session['auth.signup.role'])
        @profile.save

        if @profile.errors.present?
          @profile.errors.full_messages.each do |message|
            flash.now[:error] = message
          end

          show :'signup/complete_profile'
        else
          redirect to('/signup/success')
        end
      end

      base.get '/signup/success' do
        show :'/signup/success'
      end

      base.post '/profile' do
        current_user.update_attributes(update_params)

        if current_user.errors.present?
          current_user.errors.full_messages.each do |message|
            flash.now[:error] = message
          end
          show :'signup/complete_profile'
        else
          flash[:success] = 'Success, profile has been saved!'
          redirect to('/profile')
        end
      end

      base.get '/signup/:role' do
        roles = ['student', 'mentor']

        if roles.include? params[:role].downcase
          session['auth.signup.role'] = params[:role].downcase
          redirect to('/auth/github?redirect_uri=/signup/complete-profile')
        else
          halt 404
        end
      end

      def update_params
        (params.select {|k, v| k == 'user'}['user'] || {}).select do |k,v|
          k == 'bio' ||
            k == 'availability' ||
            k == 'skills' ||
            k == 'name' ||
            k == 'location'
        end
      end
    end
  end
end
