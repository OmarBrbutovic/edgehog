// This file is part of Edgehog.
//
// Copyright 2023 - 2026 SECO Mind Srl
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

import { zodResolver } from "@hookform/resolvers/zod";
import { useCallback, useMemo } from "react";
import type { FieldErrors } from "react-hook-form";
import { Controller, useForm } from "react-hook-form";
import { FormattedMessage, useIntl } from "react-intl";
import { graphql, useFragment } from "react-relay/hooks";

import type { UpdateChannel_ChannelFragment$key } from "@/api/__generated__/UpdateChannel_ChannelFragment.graphql";
import type { UpdateChannel_OptionsFragment$key } from "@/api/__generated__/UpdateChannel_OptionsFragment.graphql";

import Button from "@/components/Button";
import Form from "@/components/Form";
import { FormRow } from "@/components/FormRow";
import MultiSelect from "@/components/MultiSelect";
import Spinner from "@/components/Spinner";
import Stack from "@/components/Stack";
import FormFeedback from "@/forms/FormFeedback";
import {
  ChannelUpdateFormData,
  TargetGroupExtended,
  updateChannelSchema,
} from "@/forms/validation";

const UPDATE_UPDATE_CHANNEL_FRAGMENT = graphql`
  fragment UpdateChannel_ChannelFragment on Channel {
    id
    name
    handle
    targetGroups {
      edges {
        node {
          id
          name
          channel {
            id
            name
          }
        }
      }
    }
  }
`;

const UPDATE_UPDATE_CHANNEL_OPTIONS_FRAGMENT = graphql`
  fragment UpdateChannel_OptionsFragment on RootQueryType {
    deviceGroups {
      edges {
        node {
          id
          name
          channel {
            id
            name
          }
        }
      }
    }
  }
`;

type TargetGroupErrorProp = FieldErrors<ChannelUpdateFormData>["targetGroups"];

const TargetGroupsErrors = ({ error }: { error?: TargetGroupErrorProp }) => {
  const { formatMessage } = useIntl();

  const errorMessage =
    error && "message" in error
      ? (error.message as string | undefined)
      : undefined;

  if (!errorMessage) {
    return null;
  }

  return <>{formatMessage({ id: errorMessage })}</>;
};

type ChannelOutputData = {
  name: string;
  handle: string;
  targetGroupIds: string[];
};

const getTargetGroupValue = (targetGroup: TargetGroupExtended) =>
  targetGroup.id;

const transformOutputData = ({
  id: _id,
  targetGroups,
  ...rest
}: ChannelUpdateFormData): ChannelOutputData => ({
  ...rest,
  targetGroupIds: targetGroups.map((targetGroup) => targetGroup.id),
});

type Props = {
  channelRef: UpdateChannel_ChannelFragment$key;
  optionsRef: UpdateChannel_OptionsFragment$key;
  isLoading?: boolean;
  onSubmit: (data: ChannelOutputData) => void;
  onDelete: () => void;
};

const UpdateChannel = ({
  channelRef,
  optionsRef,
  isLoading = false,
  onSubmit,
  onDelete,
}: Props) => {
  const intl = useIntl();

  const channel = useFragment(UPDATE_UPDATE_CHANNEL_FRAGMENT, channelRef);

  const { deviceGroups: targetGroups } = useFragment(
    UPDATE_UPDATE_CHANNEL_OPTIONS_FRAGMENT,
    optionsRef,
  );

  const {
    register,
    handleSubmit,
    formState: { errors, isDirty },
    control,
    reset,
  } = useForm<ChannelUpdateFormData>({
    mode: "onTouched",
    // `values` automatically tracks and resets data changes (no `useEffect` needed)
    values: {
      ...channel,
      targetGroups: channel.targetGroups.edges?.map((edge) => edge.node) ?? [],
    },
    resolver: zodResolver(updateChannelSchema),
  });

  const isTargetGroupUsedByOtherChannel = useCallback(
    (targetGroup: TargetGroupExtended) =>
      targetGroup.channel !== null && targetGroup.channel.id !== channel.id,
    [channel.id],
  );

  const getTargetGroupLabel = useCallback(
    (targetGroup: TargetGroupExtended) => {
      if (!isTargetGroupUsedByOtherChannel(targetGroup)) {
        return targetGroup.name;
      }
      return intl.formatMessage(
        {
          id: "forms.UpdateChannel.targetGroupWithChannelLabel",
          defaultMessage: "{targetGroupName} (used for {channelName})",
          description:
            "Target group label of select option with optional update channel name it used for.",
        },
        {
          targetGroupName: targetGroup.name,
          channelName: targetGroup.channel?.name ?? "",
        },
      );
    },
    [intl, isTargetGroupUsedByOtherChannel],
  );

  const targetGroupOptions = useMemo(() => {
    // move disabled options to the end
    return (targetGroups?.edges?.map((edge) => edge.node) || []).toSorted(
      (group1, group2) => {
        const group1Disabled = isTargetGroupUsedByOtherChannel(group1);
        const group2Disabled = isTargetGroupUsedByOtherChannel(group2);

        if (group1Disabled === group2Disabled) return 0;
        return group1Disabled ? 1 : -1;
      },
    );
  }, [targetGroups, isTargetGroupUsedByOtherChannel]);

  const onFormSubmit = (data: ChannelUpdateFormData) => {
    onSubmit(transformOutputData(data));
  };

  const canSubmit = !isLoading && isDirty;
  const canReset = isDirty && !isLoading;

  return (
    <form onSubmit={handleSubmit(onFormSubmit)}>
      <Stack gap={3}>
        <FormRow
          id="update-channel-form-name"
          label={
            <FormattedMessage
              id="forms.UpdateChannel.nameLabel"
              defaultMessage="Name"
            />
          }
        >
          <Form.Control {...register("name")} isInvalid={!!errors.name} />
          <FormFeedback feedback={errors.name?.message} />
        </FormRow>

        <FormRow
          id="update-channel-form-handle"
          label={
            <FormattedMessage
              id="forms.UpdateChannel.handleLabel"
              defaultMessage="Handle"
            />
          }
        >
          <Form.Control {...register("handle")} isInvalid={!!errors.handle} />
          <FormFeedback feedback={errors.handle?.message} />
        </FormRow>

        <FormRow
          id="update-channel-form-target-groups"
          label={
            <FormattedMessage
              id="forms.UpdateChannel.targetGroupsLabel"
              defaultMessage="Target Groups"
            />
          }
        >
          <Controller
            name="targetGroups"
            control={control}
            render={({
              field: { value, onChange, onBlur },
              fieldState: { invalid },
            }) => (
              <MultiSelect
                invalid={invalid}
                value={value}
                onChange={onChange}
                onBlur={onBlur}
                options={targetGroupOptions}
                getOptionLabel={getTargetGroupLabel}
                getOptionValue={getTargetGroupValue}
                isOptionDisabled={isTargetGroupUsedByOtherChannel}
              />
            )}
          />
          <Form.Control.Feedback type="invalid">
            <TargetGroupsErrors error={errors.targetGroups} />
          </Form.Control.Feedback>
        </FormRow>

        <Stack
          direction="horizontal"
          gap={3}
          className="justify-content-end align-items-center"
        >
          <Button variant="primary" type="submit" disabled={!canSubmit}>
            {isLoading && <Spinner size="sm" className="me-2" />}
            <FormattedMessage
              id="forms.UpdateChannel.submitButton"
              defaultMessage="Update"
            />
          </Button>
          <Button
            variant="secondary"
            disabled={!canReset}
            onClick={() => reset()}
          >
            <FormattedMessage
              id="forms.UpdateChannel.resetButton"
              defaultMessage="Reset"
            />
          </Button>
          <Button variant="danger" onClick={onDelete}>
            <FormattedMessage
              id="forms.UpdateChannel.deleteButton"
              defaultMessage="Delete"
            />
          </Button>
        </Stack>
      </Stack>
    </form>
  );
};

export type { ChannelOutputData };

export default UpdateChannel;
