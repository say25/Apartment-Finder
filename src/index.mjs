// fetch is available in Node.js 17+
/* global fetch */

// Load the AWS SDK for Node.js
import {
  CloudWatchClient,
  PutMetricDataCommand,
} from "@aws-sdk/client-cloudwatch";

const getLastWeek = () => {
  // Date now, minus 7 days * 24 hours/day * 3600 seconds/hour * 1000 ms/s
  return new Date() - 7 * 24 * 3600 * 1000;
};

const checkForAvailableUnits = async function () {
  const url = process.env.COMPLEX_URL;
  const response = await fetch(url);

  if (!response.ok) {
    throw `Unable to get data from ${url}`;
  }

  const responseJsonData = await response.json();
  const jsonData = responseJsonData.data;

  if (!jsonData.asset.name.includes(process.env.COMPLEX_NAME)) {
    throw `Unexpected Apartment Complex ${jsonData.asset.name}`;
  }

  const createdTimeStamp = new Date(jsonData.created_at);
  if (createdTimeStamp < getLastWeek()) {
    throw `Data is older than one week, this seems wrong. Last updated ${jsonData.created_at}`;
  }

  let matchingUnits = 0;

  const availableUnits = jsonData.units;
  console.debug("availableUnits: ", availableUnits.length);

  availableUnits.forEach((unit) => {
    const unitNumber = unit.unit_number;
    // On 10th floor or higher and ends in 16
    if (unitNumber.length > 1000 && unitNumber.endsWith("16")) {
      matchingUnits++;
    }
  });

  console.debug("matchingUnits: ", matchingUnits);

  // Create CloudWatchEvents service object
  const client = new CloudWatchClient();

  const command = new PutMetricDataCommand({
    MetricData: [
      {
        MetricName: "MATCHING_UNITS",
        Dimensions: [
          {
            Name: "UNITS",
            Value: "UnitCount",
          },
        ],
        Unit: "None",
        Value: matchingUnits,
      },
      {
        MetricName: "AVAILABLE_UNITS",
        Dimensions: [
          {
            Name: "UNITS",
            Value: "UnitCount",
          },
        ],
        Unit: "None",
        Value: availableUnits.length,
      },
    ],
    Namespace: "APARTMENT_FINDER",
  });

  try {
    console.log("PutMetricDataCommand - Pending");
    const response = await client.send(command);
    console.log("PutMetricDataCommand - Completed");
    console.log(response);
  } catch (error) {
    console.error("Unable to send metric", error);
    throw error;
  }

  return "Successfully completed basicCanary checks.";
};

export const handler = async (event) => {
  console.log("checkForAvailableUnits - starting");
  console.log("Environment: ", process.env.ENVIRONMENT);
  const message = await checkForAvailableUnits();
  console.log("checkForAvailableUnits - finished");
  const response = {
    statusCode: 200,
    body: JSON.stringify(`${message}`),
  };
  return response;
};
