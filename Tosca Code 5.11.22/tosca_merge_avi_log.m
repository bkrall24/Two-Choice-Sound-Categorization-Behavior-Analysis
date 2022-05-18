function TL = tosca_merge_avi_log(TL, AVI)

for k = 1:length(TL.trials)
   
   if abs(TL.trials{k}.start - AVI(k).toscaTime) > 1
      [TL, AVI] = tosca_repair_video(TL, AVI);
%       error('Possible video error. Please tell Ken.');
   end
   
   TL.trials{k}.aviFile = AVI(k).aviFile;
   TL.trials{k}.ttosca = AVI(k).toscaTime;
   TL.trials{k}.frameRate = AVI(k).frameRate;
   
   states = TL.trials{k}.states;
   TL.trials{k} = rmfield(TL.trials{k}, 'states');

   for ks = 1:length(states)
      st = states(ks);
      
      try
        st.frames = AVI(k).states(ks).frameNum;
        st.tframe = AVI(k).states(ks).tframe;
      
        TL.trials{k}.states(ks) = st;
      catch
          disp('Error in merge avi log - more states in log than in avi log')
      end
   end
end

