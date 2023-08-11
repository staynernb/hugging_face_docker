#!/bin/bash

sendpoint=true

while getopts "u:" flag
do
    case "${flag}" in
        u) sendpoint=${OPTARG};;
    esac
done

echo "Sendpoint: $sendpoint";

id_turtlebot_docker='3a990da0f29cc4efe342dc89dafee097abeb46e36392238923971213ed8793d4'
id_huggingface_docker='dc7b02b50fb4af3166360844282cb658147c95ca4d6b80904219c5c757d60be5'

while :
do
    echo -e "\nWrite the text request: "
    read text
    echo "Text: $text"

    if [ "$text" == "rotate" ]; then
        echo "How many degrees I should rotate (clockwise): "
        read degrees

        docker exec -it $id_turtlebot_docker /bin/bash -c "
                . /opt/ros/noetic/setup.bash && 
                . /home/rosuser/catkin_ws/devel/setup.bash && 
                export ROS_MASTER_URI=http://localhost:11311 &&
                rosrun beginner_tutorials navigation.py $degrees" 
    else

        docker exec -it $id_turtlebot_docker /bin/bash -c "
            . /opt/ros/noetic/setup.bash && 
            . /home/rosuser/catkin_ws/devel/setup.bash && 
            export ROS_MASTER_URI=http://localhost:11311 &&
            rosrun beginner_tutorials listener_simu.py" 

        docker exec -it $id_huggingface_docker python /app/zero_shot.py $text
        theta=$?

        if [ $sendpoint == "true" ]; then
            echo "Sending Goal"
            docker exec -it $id_turtlebot_docker /bin/bash -c "
                . /opt/ros/noetic/setup.bash && 
                . /home/rosuser/catkin_ws/devel/setup.bash && 
                export ROS_MASTER_URI=http://localhost:11311 &&
                rosrun beginner_tutorials gotoapoint_simu.py $theta" 
        fi
    fi    

    

done
