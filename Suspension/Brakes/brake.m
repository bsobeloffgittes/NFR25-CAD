% Cam Estrada
% Updated 1/20/2024 by Siwon Ryu

%% VALUES

% Constants
mass = 690;                 % lbs
f_mass_dist = 0.46;         % percentage of mass on front axle at rest
cog_height = 11;         % inches
wheelbase = 60.25;             % inches
tire_radius = 8;            % inches
pedal_ratio = 4.9;          % mechanical advantage of pedal over master cylinder - worst case can change. 
f_pad_cof = 0.62;           % est. front pad frictional coefficient on stainless steel while warm-ish (EBC)
r_pad_cof = 0.42;           % est. rear pad frictional coefficient on stainless steel while warm-ish (Wilwood)
panic_force = 250;          % lbs
f_rotor_radius = 3.26;      % inches, measuring to center of rotor swept height
r_rotor_radius = 2.955;     % inches, measuring to center of rotor swept height 2.955
pedal_efficiency = 0.85;    % percentage efficiency of brake pedal [very arbitrary]
downforce_f_dist = 0.45;    % percentage of downforce on front axle
f_bias = 0.533;              % percentage of driver force that goes to front axle - up to .65 in either direciton. try to keep between .45 - .55. (I CHANGED THIS ONE!!!!!!!) it used to be .53
downforce_coef = 0.08589;   % downforce coefficient
max_speed = 60;             % mph (not top speed of car, but fastest speed at which data is being analyzed)

regen_torque = 70;          % lbs-ft; assumed constant regen torque at motor
axle_regen_long_force = (75 / (tire_radius / 12)) / 2;  % lbs

f_fx = 0;                   % preallocation
r_fx = 0;                   % preallocation

% Hydraulic specs
f_piston_area = 3.017;      % square inches, for ISR 22-048-OB [front calipers] (don't touch) 2.85
r_piston_area = 2.454;      % square inches, for Wilwood GP200 [rear calipers] 2.454 
f_master_cyl_area = 0.75;   % square inches, Tilton 78-series 0.5
r_master_cyl_area = 0.813;   % square inches, Tilton 78-series 0.56

%% ARRAYS

arrl = (10*max_speed) + 1;  % global array length defined by max speed 601

% All arrays go from 0-max speed mph in 0.1mph increments; note that not
% all arrays may actually be used, I just have attachment issues
fn_f_axle = zeros(1,arrl);              % front axle normal force at different speeds
fn_r_axle = zeros(1,arrl);              % rear axle normal force at different speeds
decels = zeros(1,arrl);                 % theoretical max. decel. at different speeds (limited by traction)
fpsi = zeros(1,arrl);                   % psi required in front circuit for max decel. at different speeds
rpsi = zeros(1,arrl);                   % psi required in rear circuit for max decel. at different speeds
wt = zeros(1,arrl);                     % weight transfer forwards under max decel. at different speeds = EQ 2b
fx_f_braking = zeros(1,arrl);           % front axle long. force under max decel. at different speeds
fx_r_braking = zeros(1,arrl);           % rear axle long. force under max decel. at different speeds
f_pedal_force = zeros(1,arrl);          % pedal force required for front brakes at max decel. at different speeds
r_pedal_force = zeros(1,arrl);          % pedal force required for rear brakes at max decel. at different speeds
f_pedal_force_init = zeros(1,arrl);     % front pedal force after initial traction-limited calcuation
r_pedal_force_init = zeros(1,arrl);     % rear pedal force after initial traction-limited calculation
decels_actual = zeros(1,arrl);          % "actual" max. decel. at different speeds given both traction and pedal force limitations; not 100% accurate b/c weight transfer
decels_init = zeros(1,arrl);            % stores initial traction-limited decelerations
pedal_force_delta = zeros(1,arrl);      % stores delta between front and rear pedal forces at max/ deceleration at different speeds
lowest_pedal_force = zeros(1,arrl);     

%% TRACTION-LIMITED BRAKING CASE

% Calculating axle normal forces with no braking
% F_zf0G
for i = 1:arrl
    fn_f_axle(i) = (mass * f_mass_dist) + ((downforce_coef * ((i-1)/10)^2) * downforce_f_dist);   % equal to axle normal force plus aero load at speed (i-1)/10
    fn_r_axle(i) = (mass * (1 - f_mass_dist)) + ((downforce_coef * ((i-1)/10)^2) * (1 - downforce_f_dist));
end
fprintf("\nfront axle weight 30mph = " + fn_f_axle(301) + "lbs\nfront axle weight 60mph = " + fn_f_axle(601));
fprintf("lbs\nrear axle weight 30mph = " + fn_r_axle(301) + "lbs\nrear axle weight 60mph = " + fn_r_axle(601) + "lbs\n");
% Aero loads per calculation above is within 1% of reported downforce
% values for 30mph and 60mph; downforce coefficient and formula both pulled
% from Chak's Python program modified for NFR23 parameters by Sean
% (https://colab.research.google.com/drive/1O4wubOBVq_kYNYR4lv5v6qCosen-L6RL?authuser=1#scrollTo=42kVisqC9SY6)
% 

% Calculating maximum deceleration at different speeds via nonlinear system
% of equations
 % fprintf("\ncalculating traction-limited max. decels...\n");
 % for i = 1:arrl
 %     syms a fzf fzr fxf fxr
 %     eqn1 = (fxf + fxr) / mass == a;     % deceleration based on F=ma
 %     eqn2 = 1.3*fzf - 0.0008*(fzf^2) == fxf;     % front tire long. force based on normal force
 %     eqn3 = 1.3*fzr - 0.0008*(fzr^2) == fxr;     % rear tire long. force based on normal force
 %     eqn4 = fn_f_axle(i) + (mass * (a / 9.81) * (cog_height / wheelbase)) == fzf;     % front tire normal force based on decel and speed
 %     eqn5 = fn_r_axle(i) - (mass * (a / 9.81) * (cog_height / wheelbase)) == fzr;     % rear tire normal force based on decel and speed
 %     sol = solve([eqn1, eqn2, eqn3, eqn4, eqn5], [a, fzf, fzr, fxf, fxr]);
 %     decels(i) = sol.a(2);
 % end

% Hard-coded precalculated traction-limited decels for the sake of my
% sanity -- these are the numbers that come from the systems of equations
% above with the preset values but it takes like two minutes to run it
% every time and I'm sick of waiting
%if decels(1) == 0
    decels = [1.04799321550735	1.04799430088305	1.04799755700450	1.04800298385483	1.04801058140586	1.04802034961817	1.04803228844108	1.04804639781265	1.04806267765965	1.04808112789761	1.04810174843079	1.04812453915220	1.04814949994355	1.04817663067533	1.04820593120674	1.04823740138572	1.04827104104895	1.04830685002185	1.04834482811857	1.04838497514200	1.04842729088377	1.04847177512423	1.04851842763249	1.04856724816638	1.04861823647247	1.04867139228607	1.04872671533122	1.04878420532071	1.04884386195604	1.04890568492748	1.04896967391402	1.04903582858337	1.04910414859200	1.04917463358512	1.04924728319665	1.04932209704926	1.04939907475437	1.04947821591212	1.04955952011138	1.04964298692978	1.04972861593366	1.04981640667812	1.04990635870697	1.04999847155279	1.05009274473686	1.05018917776922	1.05028777014865	1.05038852136263	1.05049143088743	1.05059649818800	1.05070372271808	1.05081310392009	1.05092464122525	1.05103833405345	1.05115418181336	1.05127218390238	1.05139233970663	1.05151464860098	1.05163910994902	1.05176572310310	1.05189448740428	1.05202540218238	1.05215846675594	1.05229368043223	1.05243104250728	1.05257055226583	1.05271220898137	1.05285601191612	1.05300196032104	1.05315005343582	1.05330029048889	1.05345267069741	1.05360719326728	1.05376385739315	1.05392266225837	1.05408360703505	1.05424669088403	1.05441191295490	1.05457927238595	1.05474876830424	1.05492039982554	1.05509416605438	1.05527006608401	1.05544809899640	1.05562826386229	1.05581055974113	1.05599498568110	1.05618154071915	1.05637022388092	1.05656103418082	1.05675397062197	1.05694903219624	1.05714621788423	1.05734552665528	1.05754695746745	1.05775050926755	1.05795618099111	1.05816397156241	1.05837387989446	1.05858590488900	1.05880004543650	1.05901630041617	1.05923466869596	1.05945514913255	1.05967774057134	1.05990244184650	1.06012925178089	1.06035816918613	1.06058919286257	1.06082232159929	1.06105755417412	1.06129488935359	1.06153432589300	1.06177586253637	1.06201949801643	1.06226523105468	1.06251306036135	1.06276298463537	1.06301500256443	1.06326911282496	1.06352531408210	1.06378360498975	1.06404398419052	1.06430645031575	1.06457100198555	1.06483763780872	1.06510635638281	1.06537715629411	1.06565003611764	1.06592499441715	1.06620202974511	1.06648114064275	1.06676232564000	1.06704558325556	1.06733091199683	1.06761831035996	1.06790777682982	1.06819930988003	1.06849290797293	1.06878856955959	1.06908629307982	1.06938607696215	1.06968791962386	1.06999181947096	1.07029777489816	1.07060578428894	1.07091584601550	1.07122795843877	1.07154211990840	1.07185832876280	1.07217658332908	1.07249688192309	1.07281922284944	1.07314360440142	1.07347002486110	1.07379848249925	1.07412897557539	1.07446150233774	1.07479606102330	1.07513264985776	1.07547126705556	1.07581191081986	1.07615457934255	1.07649927080427	1.07684598337437	1.07719471521094	1.07754546446079	1.07789822925947	1.07825300773126	1.07860979798916	1.07896859813492	1.07932940625900	1.07969222044060	1.08005703874765	1.08042385923679	1.08079267995342	1.08116349893166	1.08153631419434	1.08191112375304	1.08228792560807	1.08266671774845	1.08304749815196	1.08343026478507	1.08381501560301	1.08420174854973	1.08459046155790	1.08498115254892	1.08537381943294	1.08576846010882	1.08616507246413	1.08656365437522	1.08696420370711	1.08736671831359	1.08777119603715	1.08817763470904	1.08858603214920	1.08899638616633	1.08940869455783	1.08982295510986	1.09023916559727	1.09065732378367	1.09107742742137	1.09149947425143	1.09192346200363	1.09234938839647	1.09277725113718	1.09320704792172	1.09363877643477	1.09407243434975	1.09450801932879	1.09494552902276	1.09538496107124	1.09582631310255	1.09626958273374	1.09671476757057	1.09716186520754	1.09761087322786	1.09806178920348	1.09851461069508	1.09896933525204	1.09942596041249	1.09988448370328	1.10034490263998	1.10080721472688	1.10127141745700	1.10173750831210	1.10220548476263	1.10267534426781	1.10314708427554	1.10362070222247	1.10409619553397	1.10457356162413	1.10505279789577	1.10553390174043	1.10601687053837	1.10650170165858	1.10698839245876	1.10747694028536	1.10796734247353	1.10845959634715	1.10895369921883	1.10944964838989	1.10994744115038	1.11044707477908	1.11094854654347	1.11145185369978	1.11195699349294	1.11246396315662	1.11297275991319	1.11348338097377	1.11399582353819	1.11451008479498	1.11502616192143	1.11554405208352	1.11606375243597	1.11658526012221	1.11710857227440	1.11763368601341	1.11816059844884	1.11868930667902	1.11921980779097	1.11975209886045	1.12028617695196	1.12082203911868	1.12135968240253	1.12189910383416	1.12244030043292	1.12298326920689	1.12352800715288	1.12407451125639	1.12462277849167	1.12517280582167	1.12572459019806	1.12627812856125	1.12683341784033	1.12739045495315	1.12794923680624	1.12850976029489	1.12907202230307	1.12963601970349	1.13020174935757	1.13076920811544	1.13133839281598	1.13190930028674	1.13248192734402	1.13305627079282	1.13363232742689	1.13421009402865	1.13478956736926	1.13537074420860	1.13595362129526	1.13653819536656	1.13712446314851	1.13771242135585	1.13830206669204	1.13889339584925	1.13948640550836	1.14008109233899	1.14067745299944	1.14127548413675	1.14187518238667	1.14247654437366	1.14307956671089	1.14368424600025	1.14429057883236	1.14489856178652	1.14550819143078	1.14611946432187	1.14673237700526	1.14734692601513	1.14796310787436	1.14858091909454	1.14920035617600	1.14982141560776	1.15044409386756	1.15106838742185	1.15169429272579	1.15232180622325	1.15295092434684	1.15358164351783	1.15421396014625	1.15484787063082	1.15548337135897	1.15612045870685	1.15675912903931	1.15739937870991	1.15804120406095	1.15868460142339	1.15932956711695	1.15997609745002	1.16062418871973	1.16127383721190	1.16192503920108	1.16257779095050	1.16323208871212	1.16388792872662	1.16454530722335	1.16520422042041	1.16586466452459	1.16652663573137	1.16719013022498	1.16785514417833	1.16852167375303	1.16918971509943	1.16985926435655	1.17053031765215	1.17120287110267	1.17187692081328	1.17255246287784	1.17322949337892	1.17390800838780	1.17458800396447	1.17526947615761	1.17595242100462	1.17663683453161	1.17732271275339	1.17801005167345	1.17869884728403	1.17938909556604	1.18008079248911	1.18077393401157	1.18146851608045	1.18216453463150	1.18286198558916	1.18356086486657	1.18426116836558	1.18496289197675	1.18566603157933	1.18637058304129	1.18707654221927	1.18778390495865	1.18849266709349	1.18920282444657	1.18991437282934	1.19062730804198	1.19134162587336	1.19205732210106	1.19277439249135	1.19349283279920	1.19421263876830	1.19493380613101	1.19565633060842	1.19638020791029	1.19710543373511	1.19783200377006	1.19855991369099	1.19928915916249	1.20001973583784	1.20075163935899	1.20148486535662	1.20221940945010	1.20295526724749	1.20369243434556	1.20443090632977	1.20517067877426	1.20591174724191	1.20665410728425	1.20739775444154	1.20814268424273	1.20888889220544	1.20963637383603	1.21038512462952	1.21113514006964	1.21188641562882	1.21263894676816	1.21339272893749	1.21414775757531	1.21490402810882	1.21566153595393	1.21642027651521	1.21718024518596	1.21794143734814	1.21870384837244	1.21946747361820	1.22023230843350	1.22099834815507	1.22176558810836	1.22253402360749	1.22330364995530	1.22407446244330	1.22484645635169	1.22561962694937	1.22639396949394	1.22716947923166	1.22794615139752	1.22872398121516	1.22950296389694	1.23028309464389	1.23106436864575	1.23184678108093	1.23263032711654	1.23341500190836	1.23420080060089	1.23498771832730	1.23577575020943	1.23656489135784	1.23735513687177	1.23814648183913	1.23893892133652	1.23973245042924	1.24052706417128	1.24132275760529	1.24211952576263	1.24291736366334	1.24371626631613	1.24451622871841	1.24531724585628	1.24611931270451	1.24692242422656	1.24772657537458	1.24853176108939	1.24933797630050	1.25014521592611	1.25095347487309	1.25176274803700	1.25257303030209	1.25338431654128	1.25419660161617	1.25500988037705	1.25582414766288	1.25663939830133	1.25745562710870	1.25827282889003	1.25909099843898	1.25991013053794	1.26073021995795	1.26155126145874	1.26237324978872	1.26319617968497	1.26402004587326	1.26484484306803	1.26567056597239	1.26649720927816	1.26732476766579	1.26815323580444	1.26898260835194	1.26981287995479	1.27064404524818	1.27147609885596	1.27230903539066	1.27314284945348	1.27397753563432	1.27481308851172	1.27564950265292	1.27648677261382	1.27732489293900	1.27816385816171	1.27900366280387	1.27984430137608	1.28068576837761	1.28152805829641	1.28237116560908	1.28321508478091	1.28405981026587	1.28490533650656	1.28575165793430	1.28659876896906	1.28744666401946	1.28829533748282	1.28914478374511	1.28999499718099	1.29084597215377	1.29169770301542	1.29255018410661	1.29340340975665	1.29425737428353	1.29511207199390	1.29596749718308	1.29682364413507	1.29768050712251	1.29853808040673	1.29939635823770	1.30025533485409	1.30111500448320	1.30197536134101	1.30283639963218	1.30369811355000	1.30456049727645	1.30542354498216	1.30628725082643	1.30715160895723	1.30801661351116	1.30888225861353	1.30974853837826	1.31061544690798	1.31148297829395	1.31235112661609	1.31321988594300	1.31408925033192	1.31495921382877	1.31582977046810	1.31670091427315	1.31757263925580	1.31844493941660	1.31931780874474	1.32019124121808	1.32106523080313	1.32193977145508	1.32281485711774	1.32369048172360	1.32456663919380	1.32544332343814	1.32632052835507	1.32719824783168	1.32807647574375	1.32895520595568	1.32983443232054	1.33071414868004	1.33159434886457	1.33247502669314	1.33335617597344	1.33423779050179	1.33511986406317	1.33600239043121	1.33688536336819	1.33776877662505	1.33865262394136	1.33953689904537	1.34042159565394	1.34130670747261	1.34219222819555	1.34307815150559	1.34396447107420	1.34485118056150	1.34573827361626	1.34662574387589	1.34751358496645	1.34840179050265	1.34929035408783	1.35017926931400	1.35106852976178	1.35195812900047	1.35284806058799	1.35373831807092	1.35462889498446	1.35551978485247	1.35641098118745	1.35730247749055	1.35819426725154	1.35908634394884	1.35997870104952	1.36087133200929	1.36176423027248	1.36265738927208	1.36355080242971	1.36444446315563	1.36533836484874	1.36623250089657	1.36712686467530	1.36802144954974	1.36891624887333	1.36981125598815	1.37070646422494	1.37160186690303	1.37249745733042	1.37339322880373	1.37428917460822	1.37518528801778	1.37608156229493	1.37697799069083	1.37787456644526];
%end
fprintf("\ntraction-limited max decel from 30mph = " + decels(301) + "G\ntraction-limited max decel from 60mph = " + decels(601) + "G\n");
%decels_init = decels;

%% PEDALS-LIMITED BRAKING CASE

j = 1;  % number of loops executed
while decels(arrl) - decels_actual(arrl) > 0.001    % will converge surprisingly quickly
    if j > 1    % every loop after the first; cannot apply to first or else will never loop
        decels = decels_actual; %%%% HERE IS WHERE CODE CHANGES SUCH THAT IT CAN CONVERGE
    end
    for i = 1:arrl  % all decels
        % Calculating axle weights and corresponding max. axle longitudinal forces
        % under max decel. at different speeds
        wt(i) = mass * decels(i) * (cog_height / wheelbase); 
        fx_f_braking(i) = 1.3*(fn_f_axle(i) + wt(i)) - (0.0008*(fn_f_axle(i) + wt(i))^2); %technically already found, but didn't save in sys.eq. before so recalculating
        fx_r_braking(i) = 1.3*(fn_r_axle(i) - wt(i)) - (0.0008*(fn_r_axle(i) - wt(i))^2);
    
        % Calculating PSIs required for max decels at different speeds in front and
        % rear hydraulic loops accounting for full regen at rear axle
        fpsi(i) = ((fx_f_braking(i) / 2) * (tire_radius / f_rotor_radius)) / (f_piston_area * f_pad_cof); %/2 for each wheel
        rpsi(i) = (((fx_r_braking(i) / 2) - axle_regen_long_force) * (tire_radius / r_rotor_radius)) / (r_piston_area * r_pad_cof);
    
        % Calculating pedal forces required for max decels at different speeds for
        % front and rear circuits based on brake bias
        f_pedal_force(i) = fpsi(i) * f_master_cyl_area / pedal_ratio / pedal_efficiency / f_bias;
        r_pedal_force(i) = rpsi(i) * r_master_cyl_area / pedal_ratio / pedal_efficiency / (1 - f_bias);

        if j == 1
            f_pedal_force_init(i) = f_pedal_force(i);
            r_pedal_force_init(i) = r_pedal_force(i);
        end
        
        % Identifying lowest pedal force required to lock either axle and
        % setting that pedal force to be applied to both axles, then
        % recalculating new deceleration with updated pedal force value
        if f_pedal_force(i) < r_pedal_force(i) %easier to lock the front = find force needed to lock front and that will be max force that can be applied to rear.
            r_pedal_force(i) = f_pedal_force(i);
            r_fx = (r_pedal_force(i) * pedal_efficiency * pedal_ratio * (1 - f_bias) * r_pad_cof * r_piston_area)/(r_master_cyl_area * (tire_radius / r_rotor_radius));
            decels_actual(i) = (fx_f_braking(i) + r_fx) / mass;
        else
            f_pedal_force(i) = r_pedal_force(i);
            f_fx = (r_pedal_force(i) * pedal_efficiency * pedal_ratio * (1 - f_bias) * r_pad_cof * r_piston_area)/(r_master_cyl_area * (tire_radius / r_rotor_radius));
            decels_actual(i) = (f_fx + fx_r_braking(i)) / mass;
        end
    end
    fprintf("\nloop complete. number of loops so far: " + j);
    fprintf("\ninitial 60mph decel: " + decels(arrl) + "G\nnew 60mph decel: " + decels_actual(arrl) + "G\n");
    
    j = j + 1;
end

for i = 1:arrl
    if f_pedal_force_init(i) < r_pedal_force_init(i)
        lowest_pedal_force(i) = f_pedal_force_init(i);
    else
        lowest_pedal_force(i) = r_pedal_force_init(i);
    end
end

%% PLOTS
figure
plot(1:arrl,lowest_pedal_force(1:arrl))
legend("pedal force")
xlabel("speed, 0.1mph")
ylabel("pedal force, lbs")
title("max pedal force vs. speed")

% Plotting pedal force at threshold braking vs. deceleration at different
% speeds
figure
plot(1:arrl,f_pedal_force(1:arrl))
legend("pedal force")
xlabel("speed, 0.1mph")
ylabel("pedal force, lbs")
title("threshold pedal force vs decel")

% Plotting actual maximum deceleration at different speeds
figure
plot(1:arrl,decels_actual(1:arrl))
legend("deceleration")
xlabel("speed, 0.1mph")
ylabel("decel, G")
title("max pedal-limited decel at different speeds")

% Calculates panic force hydraulic pressures with known hydraulic and pedal
% specs
f_panic_pressure = panic_force * pedal_efficiency * pedal_ratio * f_bias / f_master_cyl_area;
r_panic_pressure = panic_force * pedal_efficiency * pedal_ratio * (1 - f_bias) / r_master_cyl_area;
fprintf("\nfront panic pressure = " + f_panic_pressure + "psi\nrear panic pressure = " + r_panic_pressure + "psi\n");

% Determining difference between front and rear pedal forces under
% threshold braking; shows brake balance -- want to target higher rear
% pedal force than front while keeping them reasonably close, and can dip
% into rear-biased braking at low speeds because stability is less
% important there, and this can of course be fine tuned as needed
if r_pedal_force_init(1) > f_pedal_force_init(1)
    fprintf("required rear pedal force is always higher than front\n");
elseif r_pedal_force_init(arrl) <= f_pedal_force_init(arrl)
    fprintf("WARNING: rear pedal force lower than fronts for all speeds\n");
else
    for i = 2:arrl
        if r_pedal_force_init(i) > f_pedal_force_init(i)
            fprintf("required rear pedal force higher than front starting at " + (i/10) + "mph\n");
            break; 
        end
    end
end

% for i = 1:arrl
%     pedal_force_delta(i) = r_pedal_force_init(i) - f_pedal_force_init(i);
% end

% Plotting front and rear pedal force at maximum deceleration vs. speed
figure
plot(1:arrl,f_pedal_force_init(1:arrl),1:arrl,r_pedal_force_init(1:arrl))
legend("front pedal force","rear pedal force")
xlabel("speed, 0.1mph")
ylabel("pedal force, lbs")  
title("front/rear pedal force delta at different speeds")

% TIME CALCS FOR THERMAL SIMS =============================================

% Calculating the amount of time it takes to decelerate from maximum speed
% to a stop assuming perfect threshold braking, i..e worst-case scenario
% from a thermal perspective, using the forward Euler method with the
% decelerations array
time = 0;
decels_actual_metric = decels_actual * 9.807;    % actual decelerations at different mph values in m/s^2
vnew = max_speed * 0.447;   % initial speed is set to max speed in m/s. 0.447 converts mph to m/s^2
vold = 0;   % vold declaration
tdelt = 0.0001;    % time step
while vnew > 0  % continues as long as the speed is greater than 0
    vold = vnew;

    % finding index of corresponding acceleration value at that given speed
    accel_ind = round(vold / 0.447 * 10) + 1;
    if accel_ind < 1
        break;
    end

    % determining change in velocity by calling corresponding value from
    % decels vector
    a = decels_actual_metric(accel_ind) * tdelt;
    vnew = vold - a;
    time = time + tdelt;

end
fprintf("\nfastest possible time to decelerate from 60mph to 0mph (ex. drag): " + time + "s\n");